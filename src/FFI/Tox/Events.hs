-- | Raw bindings to @tox_events.h@. "Network.Tox.C" is the safe API.
module FFI.Tox.Events where

import           Data.Word        (Word16, Word32, Word64, Word8)
import           FFI.Tox.Types    (EventConferenceConnectedPtr,
                                   EventConferenceInvitePtr,
                                   EventConferenceMessagePtr,
                                   EventConferencePeerListChangedPtr,
                                   EventConferencePeerNamePtr,
                                   EventConferenceTitlePtr,
                                   EventDhtNodesResponsePtr,
                                   EventFileChunkRequestPtr,
                                   EventFileRecvChunkPtr,
                                   EventFileRecvControlPtr, EventFileRecvPtr,
                                   EventFriendConnectionStatusPtr,
                                   EventFriendLosslessPacketPtr,
                                   EventFriendLossyPacketPtr,
                                   EventFriendMessagePtr, EventFriendNamePtr,
                                   EventFriendReadReceiptPtr,
                                   EventFriendRequestPtr,
                                   EventFriendStatusMessagePtr,
                                   EventFriendStatusPtr, EventFriendTypingPtr,
                                   EventGroupCustomPacketPtr,
                                   EventGroupCustomPrivatePacketPtr,
                                   EventGroupInvitePtr, EventGroupJoinFailPtr,
                                   EventGroupMessagePtr,
                                   EventGroupModerationPtr,
                                   EventGroupPasswordPtr, EventGroupPeerExitPtr,
                                   EventGroupPeerJoinPtr,
                                   EventGroupPeerLimitPtr,
                                   EventGroupPeerNamePtr,
                                   EventGroupPeerStatusPtr,
                                   EventGroupPrivacyStatePtr,
                                   EventGroupPrivateMessagePtr,
                                   EventGroupSelfJoinPtr,
                                   EventGroupTopicLockPtr, EventGroupTopicPtr,
                                   EventGroupVoiceStatePtr, EventPtr,
                                   EventSelfConnectionStatusPtr, EventsPtr,
                                   IterateOptionsPtr, SystemPtr, ToxPtr)
import           Foreign.C.Enum   (CErr)
import           Foreign.C.String (CString)
import           Foreign.C.Types  (CBool (..), CInt (..))
import           Foreign.Ptr      (Ptr)

foreign import ccall tox_event_type_to_string :: CInt -> IO CString
foreign import ccall tox_event_get_type :: EventPtr -> IO CInt
foreign import ccall tox_event_get_conference_connected
    :: EventPtr -> IO EventConferenceConnectedPtr
foreign import ccall tox_event_get_conference_invite
    :: EventPtr -> IO EventConferenceInvitePtr
foreign import ccall tox_event_get_conference_message
    :: EventPtr -> IO EventConferenceMessagePtr
foreign import ccall tox_event_get_conference_peer_list_changed
    :: EventPtr -> IO EventConferencePeerListChangedPtr
foreign import ccall tox_event_get_conference_peer_name
    :: EventPtr -> IO EventConferencePeerNamePtr
foreign import ccall tox_event_get_conference_title
    :: EventPtr -> IO EventConferenceTitlePtr
foreign import ccall tox_event_get_file_chunk_request
    :: EventPtr -> IO EventFileChunkRequestPtr
foreign import ccall tox_event_get_file_recv_chunk
    :: EventPtr -> IO EventFileRecvChunkPtr
foreign import ccall tox_event_get_file_recv_control
    :: EventPtr -> IO EventFileRecvControlPtr
foreign import ccall tox_event_get_file_recv :: EventPtr -> IO EventFileRecvPtr
foreign import ccall tox_event_get_friend_connection_status
    :: EventPtr -> IO EventFriendConnectionStatusPtr
foreign import ccall tox_event_get_friend_lossless_packet
    :: EventPtr -> IO EventFriendLosslessPacketPtr
foreign import ccall tox_event_get_friend_lossy_packet
    :: EventPtr -> IO EventFriendLossyPacketPtr
foreign import ccall tox_event_get_friend_message
    :: EventPtr -> IO EventFriendMessagePtr
foreign import ccall tox_event_get_friend_name
    :: EventPtr -> IO EventFriendNamePtr
foreign import ccall tox_event_get_friend_read_receipt
    :: EventPtr -> IO EventFriendReadReceiptPtr
foreign import ccall tox_event_get_friend_request
    :: EventPtr -> IO EventFriendRequestPtr
foreign import ccall tox_event_get_friend_status_message
    :: EventPtr -> IO EventFriendStatusMessagePtr
foreign import ccall tox_event_get_friend_status
    :: EventPtr -> IO EventFriendStatusPtr
foreign import ccall tox_event_get_friend_typing
    :: EventPtr -> IO EventFriendTypingPtr
foreign import ccall tox_event_get_self_connection_status
    :: EventPtr -> IO EventSelfConnectionStatusPtr
foreign import ccall tox_event_get_group_peer_name
    :: EventPtr -> IO EventGroupPeerNamePtr
foreign import ccall tox_event_get_group_peer_status
    :: EventPtr -> IO EventGroupPeerStatusPtr
foreign import ccall tox_event_get_group_topic
    :: EventPtr -> IO EventGroupTopicPtr
foreign import ccall tox_event_get_group_privacy_state
    :: EventPtr -> IO EventGroupPrivacyStatePtr
foreign import ccall tox_event_get_group_voice_state
    :: EventPtr -> IO EventGroupVoiceStatePtr
foreign import ccall tox_event_get_group_topic_lock
    :: EventPtr -> IO EventGroupTopicLockPtr
foreign import ccall tox_event_get_group_peer_limit
    :: EventPtr -> IO EventGroupPeerLimitPtr
foreign import ccall tox_event_get_group_password
    :: EventPtr -> IO EventGroupPasswordPtr
foreign import ccall tox_event_get_group_message
    :: EventPtr -> IO EventGroupMessagePtr
foreign import ccall tox_event_get_group_private_message
    :: EventPtr -> IO EventGroupPrivateMessagePtr
foreign import ccall tox_event_get_group_custom_packet
    :: EventPtr -> IO EventGroupCustomPacketPtr
foreign import ccall tox_event_get_group_custom_private_packet
    :: EventPtr -> IO EventGroupCustomPrivatePacketPtr
foreign import ccall tox_event_get_group_invite
    :: EventPtr -> IO EventGroupInvitePtr
foreign import ccall tox_event_get_group_peer_join
    :: EventPtr -> IO EventGroupPeerJoinPtr
foreign import ccall tox_event_get_group_peer_exit
    :: EventPtr -> IO EventGroupPeerExitPtr
foreign import ccall tox_event_get_group_self_join
    :: EventPtr -> IO EventGroupSelfJoinPtr
foreign import ccall tox_event_get_group_join_fail
    :: EventPtr -> IO EventGroupJoinFailPtr
foreign import ccall tox_event_get_group_moderation
    :: EventPtr -> IO EventGroupModerationPtr
foreign import ccall tox_event_get_dht_nodes_response
    :: EventPtr -> IO EventDhtNodesResponsePtr
foreign import ccall tox_event_conference_connected_get_conference_number
    :: EventConferenceConnectedPtr -> IO Word32
foreign import ccall tox_event_conference_invite_get_friend_number
    :: EventConferenceInvitePtr -> IO Word32
foreign import ccall tox_event_conference_invite_get_type
    :: EventConferenceInvitePtr -> IO CInt
foreign import ccall tox_event_conference_invite_get_cookie
    :: EventConferenceInvitePtr -> IO (Ptr Word8)
foreign import ccall tox_event_conference_invite_get_cookie_length
    :: EventConferenceInvitePtr -> IO Word32
foreign import ccall tox_event_conference_message_get_conference_number
    :: EventConferenceMessagePtr -> IO Word32
foreign import ccall tox_event_conference_message_get_peer_number
    :: EventConferenceMessagePtr -> IO Word32
foreign import ccall tox_event_conference_message_get_type
    :: EventConferenceMessagePtr -> IO CInt
foreign import ccall tox_event_conference_message_get_message
    :: EventConferenceMessagePtr -> IO (Ptr Word8)
foreign import ccall tox_event_conference_message_get_message_length
    :: EventConferenceMessagePtr -> IO Word32
foreign import ccall tox_event_conference_peer_list_changed_get_conference_number
    :: EventConferencePeerListChangedPtr -> IO Word32
foreign import ccall tox_event_conference_peer_name_get_conference_number
    :: EventConferencePeerNamePtr -> IO Word32
foreign import ccall tox_event_conference_peer_name_get_peer_number
    :: EventConferencePeerNamePtr -> IO Word32
foreign import ccall tox_event_conference_peer_name_get_name
    :: EventConferencePeerNamePtr -> IO (Ptr Word8)
foreign import ccall tox_event_conference_peer_name_get_name_length
    :: EventConferencePeerNamePtr -> IO Word32
foreign import ccall tox_event_conference_title_get_conference_number
    :: EventConferenceTitlePtr -> IO Word32
foreign import ccall tox_event_conference_title_get_peer_number
    :: EventConferenceTitlePtr -> IO Word32
foreign import ccall tox_event_conference_title_get_title
    :: EventConferenceTitlePtr -> IO (Ptr Word8)
foreign import ccall tox_event_conference_title_get_title_length
    :: EventConferenceTitlePtr -> IO Word32
foreign import ccall tox_event_dht_nodes_response_get_public_key
    :: EventDhtNodesResponsePtr -> IO (Ptr Word8)
foreign import ccall tox_event_dht_nodes_response_get_ip
    :: EventDhtNodesResponsePtr -> IO CString
foreign import ccall tox_event_dht_nodes_response_get_ip_length
    :: EventDhtNodesResponsePtr -> IO Word32
foreign import ccall tox_event_dht_nodes_response_get_port
    :: EventDhtNodesResponsePtr -> IO Word16
foreign import ccall tox_event_file_chunk_request_get_friend_number
    :: EventFileChunkRequestPtr -> IO Word32
foreign import ccall tox_event_file_chunk_request_get_file_number
    :: EventFileChunkRequestPtr -> IO Word32
foreign import ccall tox_event_file_chunk_request_get_position
    :: EventFileChunkRequestPtr -> IO Word64
foreign import ccall tox_event_file_chunk_request_get_length
    :: EventFileChunkRequestPtr -> IO Word16
foreign import ccall tox_event_file_recv_get_friend_number
    :: EventFileRecvPtr -> IO Word32
foreign import ccall tox_event_file_recv_get_file_number
    :: EventFileRecvPtr -> IO Word32
foreign import ccall tox_event_file_recv_get_kind
    :: EventFileRecvPtr -> IO Word32
foreign import ccall tox_event_file_recv_get_file_size
    :: EventFileRecvPtr -> IO Word64
foreign import ccall tox_event_file_recv_get_filename
    :: EventFileRecvPtr -> IO (Ptr Word8)
foreign import ccall tox_event_file_recv_get_filename_length
    :: EventFileRecvPtr -> IO Word32
foreign import ccall tox_event_file_recv_chunk_get_friend_number
    :: EventFileRecvChunkPtr -> IO Word32
foreign import ccall tox_event_file_recv_chunk_get_file_number
    :: EventFileRecvChunkPtr -> IO Word32
foreign import ccall tox_event_file_recv_chunk_get_position
    :: EventFileRecvChunkPtr -> IO Word64
foreign import ccall tox_event_file_recv_chunk_get_data
    :: EventFileRecvChunkPtr -> IO (Ptr Word8)
foreign import ccall tox_event_file_recv_chunk_get_data_length
    :: EventFileRecvChunkPtr -> IO Word32
foreign import ccall tox_event_file_recv_control_get_friend_number
    :: EventFileRecvControlPtr -> IO Word32
foreign import ccall tox_event_file_recv_control_get_file_number
    :: EventFileRecvControlPtr -> IO Word32
foreign import ccall tox_event_file_recv_control_get_control
    :: EventFileRecvControlPtr -> IO CInt
foreign import ccall tox_event_friend_connection_status_get_friend_number
    :: EventFriendConnectionStatusPtr -> IO Word32
foreign import ccall tox_event_friend_connection_status_get_connection_status
    :: EventFriendConnectionStatusPtr -> IO CInt
foreign import ccall tox_event_friend_lossless_packet_get_friend_number
    :: EventFriendLosslessPacketPtr -> IO Word32
foreign import ccall tox_event_friend_lossless_packet_get_data
    :: EventFriendLosslessPacketPtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_lossless_packet_get_data_length
    :: EventFriendLosslessPacketPtr -> IO Word32
foreign import ccall tox_event_friend_lossy_packet_get_friend_number
    :: EventFriendLossyPacketPtr -> IO Word32
foreign import ccall tox_event_friend_lossy_packet_get_data
    :: EventFriendLossyPacketPtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_lossy_packet_get_data_length
    :: EventFriendLossyPacketPtr -> IO Word32
foreign import ccall tox_event_friend_message_get_friend_number
    :: EventFriendMessagePtr -> IO Word32
foreign import ccall tox_event_friend_message_get_type
    :: EventFriendMessagePtr -> IO CInt
foreign import ccall tox_event_friend_message_get_message
    :: EventFriendMessagePtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_message_get_message_length
    :: EventFriendMessagePtr -> IO Word32
foreign import ccall tox_event_friend_name_get_friend_number
    :: EventFriendNamePtr -> IO Word32
foreign import ccall tox_event_friend_name_get_name
    :: EventFriendNamePtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_name_get_name_length
    :: EventFriendNamePtr -> IO Word32
foreign import ccall tox_event_friend_read_receipt_get_friend_number
    :: EventFriendReadReceiptPtr -> IO Word32
foreign import ccall tox_event_friend_read_receipt_get_message_id
    :: EventFriendReadReceiptPtr -> IO Word32
foreign import ccall tox_event_friend_request_get_public_key
    :: EventFriendRequestPtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_request_get_message
    :: EventFriendRequestPtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_request_get_message_length
    :: EventFriendRequestPtr -> IO Word32
foreign import ccall tox_event_friend_status_get_friend_number
    :: EventFriendStatusPtr -> IO Word32
foreign import ccall tox_event_friend_status_get_status
    :: EventFriendStatusPtr -> IO CInt
foreign import ccall tox_event_friend_status_message_get_friend_number
    :: EventFriendStatusMessagePtr -> IO Word32
foreign import ccall tox_event_friend_status_message_get_message
    :: EventFriendStatusMessagePtr -> IO (Ptr Word8)
foreign import ccall tox_event_friend_status_message_get_message_length
    :: EventFriendStatusMessagePtr -> IO Word32
foreign import ccall tox_event_friend_typing_get_friend_number
    :: EventFriendTypingPtr -> IO Word32
foreign import ccall tox_event_friend_typing_get_typing
    :: EventFriendTypingPtr -> IO CBool
foreign import ccall tox_event_group_custom_packet_get_group_number
    :: EventGroupCustomPacketPtr -> IO Word32
foreign import ccall tox_event_group_custom_packet_get_peer_id
    :: EventGroupCustomPacketPtr -> IO Word32
foreign import ccall tox_event_group_custom_packet_get_data
    :: EventGroupCustomPacketPtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_custom_packet_get_data_length
    :: EventGroupCustomPacketPtr -> IO Word32
foreign import ccall tox_event_group_custom_private_packet_get_group_number
    :: EventGroupCustomPrivatePacketPtr -> IO Word32
foreign import ccall tox_event_group_custom_private_packet_get_peer_id
    :: EventGroupCustomPrivatePacketPtr -> IO Word32
foreign import ccall tox_event_group_custom_private_packet_get_data
    :: EventGroupCustomPrivatePacketPtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_custom_private_packet_get_data_length
    :: EventGroupCustomPrivatePacketPtr -> IO Word32
foreign import ccall tox_event_group_invite_get_friend_number
    :: EventGroupInvitePtr -> IO Word32
foreign import ccall tox_event_group_invite_get_invite_data
    :: EventGroupInvitePtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_invite_get_invite_data_length
    :: EventGroupInvitePtr -> IO Word32
foreign import ccall tox_event_group_invite_get_group_name
    :: EventGroupInvitePtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_invite_get_group_name_length
    :: EventGroupInvitePtr -> IO Word32
foreign import ccall tox_event_group_join_fail_get_group_number
    :: EventGroupJoinFailPtr -> IO Word32
foreign import ccall tox_event_group_join_fail_get_fail_type
    :: EventGroupJoinFailPtr -> IO CInt
foreign import ccall tox_event_group_message_get_group_number
    :: EventGroupMessagePtr -> IO Word32
foreign import ccall tox_event_group_message_get_peer_id
    :: EventGroupMessagePtr -> IO Word32
foreign import ccall tox_event_group_message_get_message_type
    :: EventGroupMessagePtr -> IO CInt
foreign import ccall tox_event_group_message_get_message
    :: EventGroupMessagePtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_message_get_message_length
    :: EventGroupMessagePtr -> IO Word32
foreign import ccall tox_event_group_message_get_message_id
    :: EventGroupMessagePtr -> IO Word32
foreign import ccall tox_event_group_moderation_get_group_number
    :: EventGroupModerationPtr -> IO Word32
foreign import ccall tox_event_group_moderation_get_source_peer_id
    :: EventGroupModerationPtr -> IO Word32
foreign import ccall tox_event_group_moderation_get_target_peer_id
    :: EventGroupModerationPtr -> IO Word32
foreign import ccall tox_event_group_moderation_get_mod_type
    :: EventGroupModerationPtr -> IO CInt
foreign import ccall tox_event_group_password_get_group_number
    :: EventGroupPasswordPtr -> IO Word32
foreign import ccall tox_event_group_password_get_password
    :: EventGroupPasswordPtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_password_get_password_length
    :: EventGroupPasswordPtr -> IO Word32
foreign import ccall tox_event_group_peer_exit_get_group_number
    :: EventGroupPeerExitPtr -> IO Word32
foreign import ccall tox_event_group_peer_exit_get_peer_id
    :: EventGroupPeerExitPtr -> IO Word32
foreign import ccall tox_event_group_peer_exit_get_exit_type
    :: EventGroupPeerExitPtr -> IO CInt
foreign import ccall tox_event_group_peer_exit_get_name
    :: EventGroupPeerExitPtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_peer_exit_get_name_length
    :: EventGroupPeerExitPtr -> IO Word32
foreign import ccall tox_event_group_peer_exit_get_part_message
    :: EventGroupPeerExitPtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_peer_exit_get_part_message_length
    :: EventGroupPeerExitPtr -> IO Word32
foreign import ccall tox_event_group_peer_join_get_group_number
    :: EventGroupPeerJoinPtr -> IO Word32
foreign import ccall tox_event_group_peer_join_get_peer_id
    :: EventGroupPeerJoinPtr -> IO Word32
foreign import ccall tox_event_group_peer_limit_get_group_number
    :: EventGroupPeerLimitPtr -> IO Word32
foreign import ccall tox_event_group_peer_limit_get_peer_limit
    :: EventGroupPeerLimitPtr -> IO Word32
foreign import ccall tox_event_group_peer_name_get_group_number
    :: EventGroupPeerNamePtr -> IO Word32
foreign import ccall tox_event_group_peer_name_get_peer_id
    :: EventGroupPeerNamePtr -> IO Word32
foreign import ccall tox_event_group_peer_name_get_name
    :: EventGroupPeerNamePtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_peer_name_get_name_length
    :: EventGroupPeerNamePtr -> IO Word32
foreign import ccall tox_event_group_peer_status_get_group_number
    :: EventGroupPeerStatusPtr -> IO Word32
foreign import ccall tox_event_group_peer_status_get_peer_id
    :: EventGroupPeerStatusPtr -> IO Word32
foreign import ccall tox_event_group_peer_status_get_status
    :: EventGroupPeerStatusPtr -> IO CInt
foreign import ccall tox_event_group_privacy_state_get_group_number
    :: EventGroupPrivacyStatePtr -> IO Word32
foreign import ccall tox_event_group_privacy_state_get_privacy_state
    :: EventGroupPrivacyStatePtr -> IO CInt
foreign import ccall tox_event_group_private_message_get_group_number
    :: EventGroupPrivateMessagePtr -> IO Word32
foreign import ccall tox_event_group_private_message_get_peer_id
    :: EventGroupPrivateMessagePtr -> IO Word32
foreign import ccall tox_event_group_private_message_get_message_type
    :: EventGroupPrivateMessagePtr -> IO CInt
foreign import ccall tox_event_group_private_message_get_message
    :: EventGroupPrivateMessagePtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_private_message_get_message_length
    :: EventGroupPrivateMessagePtr -> IO Word32
foreign import ccall tox_event_group_private_message_get_message_id
    :: EventGroupPrivateMessagePtr -> IO Word32
foreign import ccall tox_event_group_self_join_get_group_number
    :: EventGroupSelfJoinPtr -> IO Word32
foreign import ccall tox_event_group_topic_get_group_number
    :: EventGroupTopicPtr -> IO Word32
foreign import ccall tox_event_group_topic_get_peer_id
    :: EventGroupTopicPtr -> IO Word32
foreign import ccall tox_event_group_topic_get_topic
    :: EventGroupTopicPtr -> IO (Ptr Word8)
foreign import ccall tox_event_group_topic_get_topic_length
    :: EventGroupTopicPtr -> IO Word32
foreign import ccall tox_event_group_topic_lock_get_group_number
    :: EventGroupTopicLockPtr -> IO Word32
foreign import ccall tox_event_group_topic_lock_get_topic_lock
    :: EventGroupTopicLockPtr -> IO CInt
foreign import ccall tox_event_group_voice_state_get_group_number
    :: EventGroupVoiceStatePtr -> IO Word32
foreign import ccall tox_event_group_voice_state_get_voice_state
    :: EventGroupVoiceStatePtr -> IO CInt
foreign import ccall tox_event_self_connection_status_get_connection_status
    :: EventSelfConnectionStatusPtr -> IO CInt
foreign import ccall tox_events_get_size :: EventsPtr -> IO Word32
foreign import ccall tox_events_get :: EventsPtr -> Word32 -> IO EventPtr
foreign import ccall tox_events_iterate
    :: ToxPtr -> IterateOptionsPtr -> CErr -> IO EventsPtr
foreign import ccall tox_events_dispatch
    :: ToxPtr -> EventsPtr -> Ptr () -> IO ()
foreign import ccall tox_events_free :: EventsPtr -> IO ()
foreign import ccall tox_events_bytes_size :: EventsPtr -> IO Word32
foreign import ccall tox_events_get_bytes :: EventsPtr -> Ptr Word8 -> IO CBool
foreign import ccall tox_events_load
    :: SystemPtr -> Ptr Word8 -> Word32 -> IO EventsPtr
foreign import ccall tox_events_equal
    :: SystemPtr -> EventsPtr -> EventsPtr -> IO CBool
foreign import ccall tox_events_init :: ToxPtr -> IO ()
