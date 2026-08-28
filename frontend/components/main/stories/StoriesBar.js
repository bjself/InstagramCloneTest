import { FontAwesome5 } from '@expo/vector-icons'
import React from 'react'
import { FlatList, Image, StyleSheet, Text, TouchableOpacity, View } from 'react-native'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { fetchStoriesForFollowing } from '../../../redux/actions/storiesActions'

/**
 * StoriesBar — horizontal scroll of profile pictures for users with active stories.
 * Tapping an avatar opens the StoryViewer for that user.
 */
function StoriesBar(props) {
    const { followingStories, viewedStories, navigation } = props

    if (!followingStories || followingStories.length === 0) {
        return null
    }

    const openStory = (uid, index) => {
        navigation.navigate('StoryViewer', { uid, storyIndex: index })
    }

    const renderItem = ({ item, index }) => {
        // A user's ring is unread if ANY of their stories hasn't been viewed yet
        const hasUnread = item.stories.some(s => !viewedStories[s.id])
        const user = item.user || {}

        return (
            <TouchableOpacity
                style={styles.avatarWrapper}
                onPress={() => openStory(item.uid, 0)}
                activeOpacity={0.7}
            >
                <View style={[styles.ringOuter, hasUnread ? styles.ringUnread : styles.ringRead]}>
                    <View style={styles.ringInner}>
                        {user.image && user.image !== 'default' ? (
                            <Image style={styles.avatar} source={{ uri: user.image }} />
                        ) : (
                            <View style={[styles.avatar, styles.avatarFallback]}>
                                <FontAwesome5 name="user-circle" size={44} color="#ccc" />
                            </View>
                        )}
                    </View>
                </View>
                <Text style={styles.username} numberOfLines={1}>
                    {user.name || user.username || ''}
                </Text>
            </TouchableOpacity>
        )
    }

    return (
        <View style={styles.container}>
            <FlatList
                horizontal
                showsHorizontalScrollIndicator={false}
                data={followingStories}
                keyExtractor={(item) => item.uid}
                renderItem={renderItem}
                contentContainerStyle={styles.listContent}
            />
        </View>
    )
}

const AVATAR_SIZE = 58
const RING_SIZE = AVATAR_SIZE + 6  // padding for the ring

const styles = StyleSheet.create({
    container: {
        backgroundColor: 'white',
        borderBottomWidth: 1,
        borderColor: '#ebebeb',
        paddingTop: 8,
        paddingBottom: 8,
    },
    listContent: {
        paddingLeft: 10,
        paddingRight: 10,
    },
    avatarWrapper: {
        alignItems: 'center',
        paddingRight: 14,
    },
    ringOuter: {
        width: RING_SIZE,
        height: RING_SIZE,
        borderRadius: RING_SIZE / 2,
        borderWidth: 2,
        alignItems: 'center',
        justifyContent: 'center',
    },
    ringUnread: {
        borderColor: '#3897f0',
    },
    ringRead: {
        borderColor: '#ccc',
    },
    ringInner: {
        width: AVATAR_SIZE,
        height: AVATAR_SIZE,
        borderRadius: AVATAR_SIZE / 2,
        borderWidth: 2,
        borderColor: 'white',
        overflow: 'hidden',
        alignItems: 'center',
        justifyContent: 'center',
    },
    avatar: {
        width: AVATAR_SIZE,
        height: AVATAR_SIZE,
        borderRadius: AVATAR_SIZE / 2,
    },
    avatarFallback: {
        backgroundColor: '#f0f0f0',
        alignItems: 'center',
        justifyContent: 'center',
    },
    username: {
        fontSize: 11,
        color: '#333',
        width: RING_SIZE + 8,
        textAlign: 'center',
        paddingTop: 4,
    },
})

const mapStateToProps = (store) => ({
    followingStories: store.storiesState.followingStories,
    viewedStories: store.storiesState.viewedStories,
})

const mapDispatchProps = (dispatch) =>
    bindActionCreators({ fetchStoriesForFollowing }, dispatch)

export default connect(mapStateToProps, mapDispatchProps)(StoriesBar)
