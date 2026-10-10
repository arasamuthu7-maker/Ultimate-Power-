extends Node
## First milestone: direct ENet sessions and remote hero visual/position sync.
## Public internet hosting requires a reachable host and UDP port forwarding or a hosted relay/VPS.
const PORT: int = 24560
const MAX_CLIENTS: int = 8
const AVATAR_SCRIPT = preload("res://CharacterVisual.gd")

var status_text: String = "Offline"
var last_error: String = ""
var _last_sent_position: Vector3 = Vector3.ZERO
var _send_timer: float = 0.0
var _remote_avatars: Dictionary = {}

signal connection_status_changed(message: String)

func _ready() -> void:
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(port: int = PORT) -> Error:
    disconnect_session()
    var peer := ENetMultiplayerPeer.new()
    var result: Error = peer.create_server(port, MAX_CLIENTS)
    if result != OK:
        last_error = "Could not host on UDP port %d (error %d)." % [port, result]
        _set_status(last_error)
        return result
    multiplayer.multiplayer_peer = peer
    _set_status("Hosting on UDP port %d. Share your public IP with friends." % port)
    return OK

func join_game(address: String, port: int = PORT) -> Error:
    disconnect_session()
    var clean_address := address.strip_edges()
    if clean_address.is_empty():
        last_error = "Enter the host's public IP address or hostname."
        _set_status(last_error)
        return ERR_INVALID_PARAMETER
    var peer := ENetMultiplayerPeer.new()
    var result: Error = peer.create_client(clean_address, port)
    if result != OK:
        last_error = "Could not start connection (error %d)." % result
        _set_status(last_error)
        return result
    multiplayer.multiplayer_peer = peer
    _set_status("Connecting to %s:%d..." % [clean_address, port])
    return OK

func disconnect_session() -> void:
    if multiplayer.multiplayer_peer != null:
        multiplayer.multiplayer_peer.close()
        multiplayer.multiplayer_peer = null
    for id in _remote_avatars.keys():
        var avatar: Node = _remote_avatars[id]
        if is_instance_valid(avatar):
            avatar.queue_free()
    _remote_avatars.clear()
    _set_status("Offline")

func is_online_session() -> bool:
    return multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func _process(delta: float) -> void:
    if not is_online_session():
        return
    _send_timer += delta
    if _send_timer < 0.1:
        return
    _send_timer = 0.0
    var scene := get_tree().current_scene
    if scene == null:
        return
    var player := scene.get_node_or_null("Player") as Node3D
    if player == null:
        return
    var pos: Vector3 = player.global_position
    if pos.distance_squared_to(_last_sent_position) < 0.0025:
        return
    _last_sent_position = pos
    var local_id := multiplayer.get_unique_id()
    if multiplayer.is_server():
        rpc("relay_position", local_id, pos)
    else:
        rpc_id(1, "submit_position", local_id, pos)

func _on_peer_connected(id: int) -> void:
    if not multiplayer.is_server():
        return
    _ensure_avatar(id)
    rpc("announce_player", id)
    rpc_id(id, "announce_player", multiplayer.get_unique_id())
    for existing_id in multiplayer.get_peers():
        if existing_id != id:
            rpc_id(id, "announce_player", existing_id)

func _on_peer_disconnected(id: int) -> void:
    _remove_avatar(id)
    if multiplayer.is_server():
        rpc("remove_player", id)

func _on_connected_to_server() -> void:
    _set_status("Connected! Friends can explore together. Boss raid synchronization is a later milestone.")
    rpc_id(1, "announce_player", multiplayer.get_unique_id())

func _on_connection_failed() -> void:
    last_error = "Connection failed. Check address, UDP port forwarding, and firewall."
    _set_status(last_error)
    disconnect_session()

func _on_server_disconnected() -> void:
    last_error = "Host disconnected."
    disconnect_session()

func _set_status(message: String) -> void:
    status_text = message
    connection_status_changed.emit(message)

func _ensure_avatar(id: int) -> void:
    if id == multiplayer.get_unique_id() or _remote_avatars.has(id):
        return
    var avatar := Node3D.new()
    avatar.name = "RemotePlayer_%d" % id
    avatar.set_script(AVATAR_SCRIPT)
    avatar.set("character_style", "hero")
    avatar.set_meta("network_peer_id", id)
    var scene := get_tree().current_scene
    if scene != null:
        scene.add_child(avatar)
        _remote_avatars[id] = avatar

func _remove_avatar(id: int) -> void:
    if not _remote_avatars.has(id):
        return
    var avatar: Node = _remote_avatars[id]
    if is_instance_valid(avatar):
        avatar.queue_free()
    _remote_avatars.erase(id)

@rpc("any_peer", "call_remote", "reliable")
func announce_player(id: int) -> void:
    var sender := multiplayer.get_remote_sender_id()
    if multiplayer.is_server():
        if sender != 0 and sender != id:
            return
        _ensure_avatar(id)
        if sender == id:
            rpc("announce_player", id)
    elif sender == 1:
        _ensure_avatar(id)

@rpc("any_peer", "call_remote", "reliable")
func remove_player(id: int) -> void:
    if multiplayer.get_remote_sender_id() != 1 and not multiplayer.is_server():
        return
    _remove_avatar(id)

@rpc("any_peer", "call_remote", "unreliable")
func submit_position(id: int, pos: Vector3) -> void:
    if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != id:
        return
    _ensure_avatar(id)
    _apply_remote_position(id, pos)
    rpc("relay_position", id, pos)

@rpc("any_peer", "call_remote", "unreliable")
func relay_position(id: int, pos: Vector3) -> void:
    if multiplayer.is_server() and multiplayer.get_remote_sender_id() != 0:
        return
    _apply_remote_position(id, pos)

func _apply_remote_position(id: int, pos: Vector3) -> void:
    if id == multiplayer.get_unique_id():
        return
    _ensure_avatar(id)
    if _remote_avatars.has(id):
        var avatar: Node3D = _remote_avatars[id]
        if is_instance_valid(avatar):
            avatar.global_position = pos
