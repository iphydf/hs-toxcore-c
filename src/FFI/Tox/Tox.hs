-- | Raw bindings to @tox.h@. "Network.Tox.C" is the safe API.
module FFI.Tox.Tox where

import           Data.Word        (Word16, Word32, Word64, Word8)
import           FFI.Tox.Types    (ConferenceConnectedCb, ConferenceInviteCb,
                                   ConferenceMessageCb,
                                   ConferencePeerListChangedCb,
                                   ConferencePeerNameCb, ConferenceTitleCb,
                                   FileChunkRequestCb, FileRecvCb,
                                   FileRecvChunkCb, FileRecvControlCb,
                                   FriendConnectionStatusCb,
                                   FriendLosslessPacketCb, FriendLossyPacketCb,
                                   FriendMessageCb, FriendNameCb,
                                   FriendReadReceiptCb, FriendRequestCb,
                                   FriendStatusCb, FriendStatusMessageCb,
                                   FriendTypingCb, GroupCustomPacketCb,
                                   GroupCustomPrivatePacketCb, GroupInviteCb,
                                   GroupJoinFailCb, GroupMessageCb,
                                   GroupModerationCb, GroupPasswordCb,
                                   GroupPeerExitCb, GroupPeerJoinCb,
                                   GroupPeerLimitCb, GroupPeerNameCb,
                                   GroupPeerStatusCb, GroupPrivacyStateCb,
                                   GroupPrivateMessageCb, GroupSelfJoinCb,
                                   GroupTopicCb, GroupTopicLockCb,
                                   GroupVoiceStateCb, OptionsPtr,
                                   SelfConnectionStatusCb, ToxPtr)
import           Foreign.C.Enum   (CErr)
import           Foreign.C.String (CString)
import           Foreign.C.Types  (CBool (..), CInt (..), CSize (..))
import           Foreign.Ptr      (FunPtr, Ptr)

foreign import ccall tox_conference_id_size :: Word32
foreign import ccall tox_conference_type_to_string :: CInt -> IO CString
foreign import ccall tox_conference_new :: ToxPtr -> CErr -> IO Word32
foreign import ccall tox_conference_delete
    :: ToxPtr -> Word32 -> CErr -> IO CBool
foreign import ccall tox_conference_peer_count
    :: ToxPtr -> Word32 -> CErr -> IO Word32
foreign import ccall tox_conference_offline_peer_count
    :: ToxPtr -> Word32 -> CErr -> IO Word32
foreign import ccall tox_conference_set_max_offline
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall tox_conference_join
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO Word32
foreign import ccall tox_conference_send_message
    :: ToxPtr -> Word32 -> CInt -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_conference_get_title_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_conference_get_title
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_conference_set_title
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_conference_get_type
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_conference_get_id
    :: ToxPtr -> Word32 -> Ptr Word8 -> IO CBool
foreign import ccall tox_conference_by_id
    :: ToxPtr -> Ptr Word8 -> CErr -> IO Word32
foreign import ccall tox_conference_offline_peer_get_name_size
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CSize
foreign import ccall tox_conference_offline_peer_get_name
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_conference_offline_peer_get_public_key
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_conference_offline_peer_get_last_active
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO Word64
foreign import ccall tox_conference_peer_get_name_size
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CSize
foreign import ccall tox_conference_peer_get_name
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_conference_peer_get_public_key
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_conference_peer_number_is_ours
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall tox_file_id_length :: Word32
foreign import ccall tox_file_control_to_string :: CInt -> IO CString
foreign import ccall tox_file_by_id
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO Word32
foreign import ccall tox_file_send
    :: ToxPtr
    -> Word32
    -> Word32
    -> Word64
    -> Ptr Word8
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO Word32
foreign import ccall tox_friend_add
    :: ToxPtr -> Ptr Word8 -> Ptr Word8 -> CSize -> CErr -> IO Word32
foreign import ccall tox_friend_add_norequest
    :: ToxPtr -> Ptr Word8 -> CErr -> IO Word32
foreign import ccall tox_friend_delete :: ToxPtr -> Word32 -> CErr -> IO CBool
foreign import ccall tox_friend_by_public_key
    :: ToxPtr -> Ptr Word8 -> CErr -> IO Word32
foreign import ccall tox_friend_exists :: ToxPtr -> Word32 -> IO CBool
foreign import ccall tox_friend_get_public_key
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_friend_get_last_online
    :: ToxPtr -> Word32 -> CErr -> IO Word64
foreign import ccall tox_friend_get_name_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_friend_get_name
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_friend_get_status_message_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_friend_get_status_message
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_friend_get_status
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_friend_get_connection_status
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_friend_get_typing
    :: ToxPtr -> Word32 -> CErr -> IO CBool
foreign import ccall tox_friend_send_message
    :: ToxPtr -> Word32 -> CInt -> Ptr Word8 -> CSize -> CErr -> IO Word32
foreign import ccall tox_friend_send_lossy_packet
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_friend_send_lossless_packet
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_group_max_topic_length :: Word32
foreign import ccall tox_group_max_part_length :: Word32
foreign import ccall tox_group_max_message_length :: Word32
foreign import ccall tox_group_max_custom_lossy_packet_length :: Word32
foreign import ccall tox_group_max_custom_lossless_packet_length :: Word32
foreign import ccall tox_group_max_group_name_length :: Word32
foreign import ccall tox_group_max_password_size :: Word32
foreign import ccall tox_group_chat_id_size :: Word32
foreign import ccall tox_group_privacy_state_to_string :: CInt -> IO CString
foreign import ccall tox_group_topic_lock_to_string :: CInt -> IO CString
foreign import ccall tox_group_voice_state_to_string :: CInt -> IO CString
foreign import ccall tox_group_role_to_string :: CInt -> IO CString
foreign import ccall tox_group_new
    :: ToxPtr
    -> CInt
    -> Ptr Word8
    -> CSize
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO Word32
foreign import ccall tox_group_join
    :: ToxPtr
    -> Ptr Word8
    -> Ptr Word8
    -> CSize
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO Word32
foreign import ccall tox_group_is_connected
    :: ToxPtr -> Word32 -> CErr -> IO CBool
foreign import ccall tox_group_disconnect
    :: ToxPtr -> Word32 -> CErr -> IO CBool
foreign import ccall tox_group_leave
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_group_self_set_name
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_group_self_get_name_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_group_self_get_name
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_self_set_status
    :: ToxPtr -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall tox_group_self_get_status
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_self_get_role
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_self_get_peer_id
    :: ToxPtr -> Word32 -> CErr -> IO Word32
foreign import ccall tox_group_self_get_public_key
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_set_topic
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_group_get_topic_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_group_get_topic
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_get_name_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_group_get_name
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_get_chat_id
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_by_id :: ToxPtr -> Ptr Word8 -> CErr -> IO Word32
foreign import ccall tox_group_get_privacy_state
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_get_voice_state
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_get_topic_lock
    :: ToxPtr -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_get_peer_limit
    :: ToxPtr -> Word32 -> CErr -> IO Word16
foreign import ccall tox_group_get_password_size
    :: ToxPtr -> Word32 -> CErr -> IO CSize
foreign import ccall tox_group_get_password
    :: ToxPtr -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_send_message
    :: ToxPtr -> Word32 -> CInt -> Ptr Word8 -> CSize -> CErr -> IO Word32
foreign import ccall tox_group_send_private_message
    :: ToxPtr
    -> Word32
    -> Word32
    -> CInt
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO Word32
foreign import ccall tox_group_send_custom_packet
    :: ToxPtr -> Word32 -> CBool -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_group_send_custom_private_packet
    :: ToxPtr
    -> Word32
    -> Word32
    -> CBool
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO CBool
foreign import ccall tox_group_invite_friend
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall tox_group_invite_accept
    :: ToxPtr
    -> Word32
    -> Ptr Word8
    -> CSize
    -> Ptr Word8
    -> CSize
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO Word32
foreign import ccall tox_group_exit_type_to_string :: CInt -> IO CString
foreign import ccall tox_group_join_fail_to_string :: CInt -> IO CString
foreign import ccall tox_group_set_password
    :: ToxPtr -> Word32 -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_group_set_topic_lock
    :: ToxPtr -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall tox_group_set_voice_state
    :: ToxPtr -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall tox_group_set_privacy_state
    :: ToxPtr -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall tox_group_set_peer_limit
    :: ToxPtr -> Word32 -> Word16 -> CErr -> IO CBool
foreign import ccall tox_group_set_ignore
    :: ToxPtr -> Word32 -> Word32 -> CBool -> CErr -> IO CBool
foreign import ccall tox_group_set_role
    :: ToxPtr -> Word32 -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall tox_group_kick_peer
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall tox_group_mod_event_to_string :: CInt -> IO CString
foreign import ccall tox_group_peer_public_key_size :: Word32
foreign import ccall tox_group_peer_get_name_size
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CSize
foreign import ccall tox_group_peer_get_name
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_group_peer_get_status
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_peer_get_role
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_peer_get_connection_status
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CInt
foreign import ccall tox_group_peer_get_public_key
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_version_major :: Word32
foreign import ccall tox_version_minor :: Word32
foreign import ccall tox_version_patch :: Word32
foreign import ccall tox_version_is_compatible
    :: Word32 -> Word32 -> Word32 -> IO CBool
foreign import ccall tox_public_key_size :: Word32
foreign import ccall tox_secret_key_size :: Word32
foreign import ccall tox_dht_id_size :: Word32
foreign import ccall tox_nospam_size :: Word32
foreign import ccall tox_address_size :: Word32
foreign import ccall tox_max_name_length :: Word32
foreign import ccall tox_max_status_message_length :: Word32
foreign import ccall tox_max_friend_request_length :: Word32
foreign import ccall tox_max_message_length :: Word32
foreign import ccall tox_max_custom_packet_size :: Word32
foreign import ccall tox_hash_length :: Word32
foreign import ccall tox_max_filename_length :: Word32
foreign import ccall tox_max_hostname_length :: Word32
foreign import ccall tox_user_status_to_string :: CInt -> IO CString
foreign import ccall tox_message_type_to_string :: CInt -> IO CString
foreign import ccall tox_err_new_to_string :: CInt -> IO CString
foreign import ccall tox_new :: OptionsPtr -> CErr -> IO ToxPtr
foreign import ccall tox_kill :: ToxPtr -> IO ()
foreign import ccall tox_get_savedata_size :: ToxPtr -> IO CSize
foreign import ccall tox_get_savedata :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_err_bootstrap_to_string :: CInt -> IO CString
foreign import ccall tox_bootstrap
    :: ToxPtr -> CString -> Word16 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_add_tcp_relay
    :: ToxPtr -> CString -> Word16 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_connection_to_string :: CInt -> IO CString
foreign import ccall tox_self_get_connection_status :: ToxPtr -> IO CInt
foreign import ccall tox_iteration_interval :: ToxPtr -> IO Word32
foreign import ccall tox_iterate :: ToxPtr -> Ptr () -> IO ()
foreign import ccall tox_self_get_address :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_self_set_nospam :: ToxPtr -> Word32 -> IO ()
foreign import ccall tox_self_get_nospam :: ToxPtr -> IO Word32
foreign import ccall tox_self_get_public_key :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_self_get_secret_key :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_err_set_info_to_string :: CInt -> IO CString
foreign import ccall tox_self_set_name
    :: ToxPtr -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_self_get_name_size :: ToxPtr -> IO CSize
foreign import ccall tox_self_get_name :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_self_set_status_message
    :: ToxPtr -> Ptr Word8 -> CSize -> CErr -> IO CBool
foreign import ccall tox_self_get_status_message_size :: ToxPtr -> IO CSize
foreign import ccall tox_self_get_status_message :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_self_set_status :: ToxPtr -> CInt -> IO ()
foreign import ccall tox_self_get_status :: ToxPtr -> IO CInt
foreign import ccall tox_err_friend_add_to_string :: CInt -> IO CString
foreign import ccall tox_err_friend_delete_to_string :: CInt -> IO CString
foreign import ccall tox_err_friend_by_public_key_to_string
    :: CInt -> IO CString
foreign import ccall tox_self_get_friend_list_size :: ToxPtr -> IO CSize
foreign import ccall tox_self_get_friend_list :: ToxPtr -> Ptr Word32 -> IO ()
foreign import ccall tox_err_friend_get_public_key_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_friend_get_last_online_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_friend_query_to_string :: CInt -> IO CString
foreign import ccall tox_err_set_typing_to_string :: CInt -> IO CString
foreign import ccall tox_self_set_typing
    :: ToxPtr -> Word32 -> CBool -> CErr -> IO CBool
foreign import ccall tox_err_friend_send_message_to_string :: CInt -> IO CString
foreign import ccall tox_hash :: Ptr Word8 -> Ptr Word8 -> CSize -> IO CBool
foreign import ccall tox_err_file_control_to_string :: CInt -> IO CString
foreign import ccall tox_file_control
    :: ToxPtr -> Word32 -> Word32 -> CInt -> CErr -> IO CBool
foreign import ccall tox_err_file_seek_to_string :: CInt -> IO CString
foreign import ccall tox_file_seek
    :: ToxPtr -> Word32 -> Word32 -> Word64 -> CErr -> IO CBool
foreign import ccall tox_err_file_get_to_string :: CInt -> IO CString
foreign import ccall tox_file_get_file_id
    :: ToxPtr -> Word32 -> Word32 -> Ptr Word8 -> CErr -> IO CBool
foreign import ccall tox_err_file_by_id_to_string :: CInt -> IO CString
foreign import ccall tox_err_file_send_to_string :: CInt -> IO CString
foreign import ccall tox_err_file_send_chunk_to_string :: CInt -> IO CString
foreign import ccall tox_file_send_chunk
    :: ToxPtr
    -> Word32
    -> Word32
    -> Word64
    -> Ptr Word8
    -> CSize
    -> CErr
    -> IO CBool
foreign import ccall tox_err_conference_new_to_string :: CInt -> IO CString
foreign import ccall tox_err_conference_delete_to_string :: CInt -> IO CString
foreign import ccall tox_err_conference_peer_query_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_conference_set_max_offline_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_conference_invite_to_string :: CInt -> IO CString
foreign import ccall tox_conference_invite
    :: ToxPtr -> Word32 -> Word32 -> CErr -> IO CBool
foreign import ccall tox_err_conference_join_to_string :: CInt -> IO CString
foreign import ccall tox_err_conference_send_message_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_conference_title_to_string :: CInt -> IO CString
foreign import ccall tox_conference_get_chatlist_size :: ToxPtr -> IO CSize
foreign import ccall tox_conference_get_chatlist
    :: ToxPtr -> Ptr Word32 -> IO ()
foreign import ccall tox_err_conference_get_type_to_string :: CInt -> IO CString
foreign import ccall tox_err_conference_by_id_to_string :: CInt -> IO CString
foreign import ccall tox_err_conference_by_uid_to_string :: CInt -> IO CString
foreign import ccall tox_err_friend_custom_packet_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_get_port_to_string :: CInt -> IO CString
foreign import ccall tox_self_get_dht_id :: ToxPtr -> Ptr Word8 -> IO ()
foreign import ccall tox_self_get_udp_port :: ToxPtr -> CErr -> IO Word16
foreign import ccall tox_self_get_tcp_port :: ToxPtr -> CErr -> IO Word16
foreign import ccall tox_err_group_new_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_join_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_is_connected_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_disconnect_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_reconnect_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_leave_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_self_query_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_self_name_set_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_self_status_set_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_peer_query_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_state_query_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_topic_set_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_by_id_to_string :: CInt -> IO CString
foreign import ccall tox_group_get_group_list_size :: ToxPtr -> IO Word32
foreign import ccall tox_group_get_group_list :: ToxPtr -> Ptr Word32 -> IO ()
foreign import ccall tox_err_group_send_message_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_send_private_message_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_send_custom_packet_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_send_custom_private_packet_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_invite_friend_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_invite_accept_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_set_password_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_set_topic_lock_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_set_voice_state_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_set_privacy_state_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_set_peer_limit_to_string
    :: CInt -> IO CString
foreign import ccall tox_err_group_set_ignore_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_set_role_to_string :: CInt -> IO CString
foreign import ccall tox_err_group_kick_peer_to_string :: CInt -> IO CString
foreign import ccall tox_callback_self_connection_status
    :: ToxPtr -> FunPtr SelfConnectionStatusCb -> IO ()
foreign import ccall tox_callback_friend_name
    :: ToxPtr -> FunPtr FriendNameCb -> IO ()
foreign import ccall tox_callback_friend_status_message
    :: ToxPtr -> FunPtr FriendStatusMessageCb -> IO ()
foreign import ccall tox_callback_friend_status
    :: ToxPtr -> FunPtr FriendStatusCb -> IO ()
foreign import ccall tox_callback_friend_connection_status
    :: ToxPtr -> FunPtr FriendConnectionStatusCb -> IO ()
foreign import ccall tox_callback_friend_typing
    :: ToxPtr -> FunPtr FriendTypingCb -> IO ()
foreign import ccall tox_callback_friend_read_receipt
    :: ToxPtr -> FunPtr FriendReadReceiptCb -> IO ()
foreign import ccall tox_callback_friend_request
    :: ToxPtr -> FunPtr FriendRequestCb -> IO ()
foreign import ccall tox_callback_friend_message
    :: ToxPtr -> FunPtr FriendMessageCb -> IO ()
foreign import ccall tox_callback_file_recv_control
    :: ToxPtr -> FunPtr FileRecvControlCb -> IO ()
foreign import ccall tox_callback_file_chunk_request
    :: ToxPtr -> FunPtr FileChunkRequestCb -> IO ()
foreign import ccall tox_callback_file_recv
    :: ToxPtr -> FunPtr FileRecvCb -> IO ()
foreign import ccall tox_callback_file_recv_chunk
    :: ToxPtr -> FunPtr FileRecvChunkCb -> IO ()
foreign import ccall tox_callback_conference_invite
    :: ToxPtr -> FunPtr ConferenceInviteCb -> IO ()
foreign import ccall tox_callback_conference_connected
    :: ToxPtr -> FunPtr ConferenceConnectedCb -> IO ()
foreign import ccall tox_callback_conference_message
    :: ToxPtr -> FunPtr ConferenceMessageCb -> IO ()
foreign import ccall tox_callback_conference_title
    :: ToxPtr -> FunPtr ConferenceTitleCb -> IO ()
foreign import ccall tox_callback_conference_peer_name
    :: ToxPtr -> FunPtr ConferencePeerNameCb -> IO ()
foreign import ccall tox_callback_conference_peer_list_changed
    :: ToxPtr -> FunPtr ConferencePeerListChangedCb -> IO ()
foreign import ccall tox_callback_friend_lossy_packet
    :: ToxPtr -> FunPtr FriendLossyPacketCb -> IO ()
foreign import ccall tox_callback_friend_lossless_packet
    :: ToxPtr -> FunPtr FriendLosslessPacketCb -> IO ()
foreign import ccall tox_callback_group_peer_name
    :: ToxPtr -> FunPtr GroupPeerNameCb -> IO ()
foreign import ccall tox_callback_group_peer_status
    :: ToxPtr -> FunPtr GroupPeerStatusCb -> IO ()
foreign import ccall tox_callback_group_topic
    :: ToxPtr -> FunPtr GroupTopicCb -> IO ()
foreign import ccall tox_callback_group_privacy_state
    :: ToxPtr -> FunPtr GroupPrivacyStateCb -> IO ()
foreign import ccall tox_callback_group_voice_state
    :: ToxPtr -> FunPtr GroupVoiceStateCb -> IO ()
foreign import ccall tox_callback_group_topic_lock
    :: ToxPtr -> FunPtr GroupTopicLockCb -> IO ()
foreign import ccall tox_callback_group_peer_limit
    :: ToxPtr -> FunPtr GroupPeerLimitCb -> IO ()
foreign import ccall tox_callback_group_password
    :: ToxPtr -> FunPtr GroupPasswordCb -> IO ()
foreign import ccall tox_callback_group_message
    :: ToxPtr -> FunPtr GroupMessageCb -> IO ()
foreign import ccall tox_callback_group_private_message
    :: ToxPtr -> FunPtr GroupPrivateMessageCb -> IO ()
foreign import ccall tox_callback_group_custom_packet
    :: ToxPtr -> FunPtr GroupCustomPacketCb -> IO ()
foreign import ccall tox_callback_group_custom_private_packet
    :: ToxPtr -> FunPtr GroupCustomPrivatePacketCb -> IO ()
foreign import ccall tox_callback_group_invite
    :: ToxPtr -> FunPtr GroupInviteCb -> IO ()
foreign import ccall tox_callback_group_peer_join
    :: ToxPtr -> FunPtr GroupPeerJoinCb -> IO ()
foreign import ccall tox_callback_group_peer_exit
    :: ToxPtr -> FunPtr GroupPeerExitCb -> IO ()
foreign import ccall tox_callback_group_self_join
    :: ToxPtr -> FunPtr GroupSelfJoinCb -> IO ()
foreign import ccall tox_callback_group_join_fail
    :: ToxPtr -> FunPtr GroupJoinFailCb -> IO ()
foreign import ccall tox_callback_group_moderation
    :: ToxPtr -> FunPtr GroupModerationCb -> IO ()
