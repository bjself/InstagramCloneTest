import { Feather, FontAwesome5 } from '@expo/vector-icons'
import { Video } from 'expo-av'
import React, { useCallback, useEffect, useRef, useState } from 'react'
import {
    Animated,
    Dimensions,
    Image,
    PanResponder,
    StyleSheet,
    Text,
    TouchableOpacity,
    TouchableWithoutFeedback,
    View,
} from 'react-native'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { markStoryViewed } from '../../../redux/actions/storiesActions'

const WINDOW_WIDTH = Dimensions.get('window').width
const WINDOW_HEIGHT = Dimensions.get('window').height
const STORY_DURATION_MS = 5000  // 5 s per photo; video auto-advances when done
const STORY_TTL_MS = 24 * 60 * 60 * 1000

function msUntilExpiry(story) {
    if (!story.creation) return 0
    const created = story.creation.toDate ? story.creation.toDate() : new Date(story.creation)
    return Math.max(0, STORY_TTL_MS - (Date.now() - created.getTime()))
}

function formatTimeLeft(ms) {
    const hours = Math.floor(ms / 3600000)
    const mins = Math.floor((ms % 3600000) / 60000)
    if (hours > 0) return `${hours}h left`
    if (mins > 0) return `${mins}m left`
    return 'Expiring soon'
}

function StoryViewer(props) {
    const { route, navigation, markStoryViewed, viewedStories } = props
    const { uid } = route.params

    // Find this user's stories from Redux
    const userStoryGroup = props.followingStories.find(g => g.uid === uid)
    const user = userStoryGroup ? userStoryGroup.user : {}
    const stories = userStoryGroup ? userStoryGroup.stories : []

    const [currentIndex, setCurrentIndex] = useState(route.params.storyIndex || 0)
    const [paused, setPaused] = useState(false)

    const progressAnim = useRef(new Animated.Value(0)).current
    const progressAnimation = useRef(null)

    const currentStory = stories[currentIndex] || null

    const advance = useCallback(() => {
        if (currentIndex < stories.length - 1) {
            setCurrentIndex(i => i + 1)
        } else {
            navigation.goBack()
        }
    }, [currentIndex, stories.length, navigation])

    const goBack = useCallback(() => {
        if (currentIndex > 0) {
            setCurrentIndex(i => i - 1)
        }
    }, [currentIndex])

    // Mark viewed and start progress bar whenever story changes
    useEffect(() => {
        if (!currentStory) return

        markStoryViewed(uid, currentStory.id)

        progressAnim.setValue(0)
        if (progressAnimation.current) {
            progressAnimation.current.stop()
        }

        if (!paused && currentStory.type === 1) {
            // Photo — auto-advance after STORY_DURATION_MS
            progressAnimation.current = Animated.timing(progressAnim, {
                toValue: 1,
                duration: STORY_DURATION_MS,
                useNativeDriver: false,
            })
            progressAnimation.current.start(({ finished }) => {
                if (finished) advance()
            })
        }

        return () => {
            if (progressAnimation.current) {
                progressAnimation.current.stop()
            }
        }
    }, [currentIndex, paused])

    // Pause / resume on hold
    const panResponder = useRef(
        PanResponder.create({
            onStartShouldSetPanResponder: () => true,
            onPanResponderGrant: () => setPaused(true),
            onPanResponderRelease: () => setPaused(false),
            onPanResponderTerminate: () => setPaused(false),
        })
    ).current

    useEffect(() => {
        if (!currentStory || currentStory.type !== 1) return
        if (paused) {
            if (progressAnimation.current) progressAnimation.current.stop()
        } else {
            // Restart from current position isn't trivially available via Animated;
            // restart from zero on resume (keeps UX simple and matches MVP scope)
            progressAnim.setValue(0)
            progressAnimation.current = Animated.timing(progressAnim, {
                toValue: 1,
                duration: STORY_DURATION_MS,
                useNativeDriver: false,
            })
            progressAnimation.current.start(({ finished }) => {
                if (finished) advance()
            })
        }
    }, [paused])

    if (!currentStory) {
        return (
            <View style={styles.container}>
                <TouchableOpacity style={styles.closeButton} onPress={() => navigation.goBack()}>
                    <Feather name="x" size={28} color="white" />
                </TouchableOpacity>
                <Text style={styles.emptyText}>No stories available</Text>
            </View>
        )
    }

    const timeLeftMs = msUntilExpiry(currentStory)
    const timeLabel = formatTimeLeft(timeLeftMs)
    const mediaUrl = currentStory.type === 1 ? currentStory.photoUrl : currentStory.videoUrl

    return (
        <View style={styles.container} {...panResponder.panHandlers}>
            {/* ── Progress bars ── */}
            <View style={styles.progressContainer}>
                {stories.map((s, i) => (
                    <View key={s.id} style={styles.progressTrack}>
                        <Animated.View
                            style={[
                                styles.progressFill,
                                {
                                    width: i < currentIndex
                                        ? '100%'
                                        : i === currentIndex
                                            ? progressAnim.interpolate({
                                                inputRange: [0, 1],
                                                outputRange: ['0%', '100%'],
                                            })
                                            : '0%',
                                },
                            ]}
                        />
                    </View>
                ))}
            </View>

            {/* ── Header ── */}
            <View style={styles.header}>
                {user.image && user.image !== 'default' ? (
                    <Image style={styles.headerAvatar} source={{ uri: user.image }} />
                ) : (
                    <FontAwesome5 name="user-circle" size={32} color="white" />
                )}
                <Text style={styles.headerName}>{user.name || user.username || ''}</Text>
                <Text style={styles.timeLabel}>{timeLabel}</Text>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.closeButton}>
                    <Feather name="x" size={26} color="white" />
                </TouchableOpacity>
            </View>

            {/* ── Media ── */}
            {currentStory.type === 1 ? (
                <Image
                    source={{ uri: mediaUrl }}
                    style={styles.media}
                    resizeMode="cover"
                />
            ) : (
                <Video
                    source={{ uri: mediaUrl }}
                    style={styles.media}
                    resizeMode="cover"
                    shouldPlay={!paused}
                    isLooping={false}
                    onPlaybackStatusUpdate={(status) => {
                        if (status.didJustFinish) advance()
                        if (status.isPlaying && status.durationMillis > 0) {
                            progressAnim.setValue(
                                status.positionMillis / status.durationMillis
                            )
                        }
                    }}
                />
            )}

            {/* ── Tap zones for prev/next ── */}
            <View style={styles.tapZones}>
                <TouchableWithoutFeedback onPress={goBack}>
                    <View style={styles.tapLeft} />
                </TouchableWithoutFeedback>
                <TouchableWithoutFeedback onPress={advance}>
                    <View style={styles.tapRight} />
                </TouchableWithoutFeedback>
            </View>

            {/* ── Footer ── */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>
                    Viewed by {currentStory.viewCount || 0}{' '}
                    {currentStory.viewCount === 1 ? 'person' : 'people'}
                </Text>
            </View>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'black',
    },
    media: {
        width: WINDOW_WIDTH,
        height: WINDOW_HEIGHT,
        position: 'absolute',
        top: 0,
        left: 0,
    },
    progressContainer: {
        flexDirection: 'row',
        position: 'absolute',
        top: 44,
        left: 8,
        right: 8,
        zIndex: 10,
        gap: 4,
    },
    progressTrack: {
        flex: 1,
        height: 2,
        backgroundColor: 'rgba(255,255,255,0.4)',
        borderRadius: 2,
        overflow: 'hidden',
    },
    progressFill: {
        height: '100%',
        backgroundColor: 'white',
    },
    header: {
        position: 'absolute',
        top: 54,
        left: 10,
        right: 10,
        flexDirection: 'row',
        alignItems: 'center',
        zIndex: 10,
    },
    headerAvatar: {
        width: 32,
        height: 32,
        borderRadius: 16,
        borderWidth: 1,
        borderColor: 'white',
    },
    headerName: {
        color: 'white',
        fontWeight: '600',
        fontSize: 14,
        paddingLeft: 8,
        flex: 1,
    },
    timeLabel: {
        color: 'rgba(255,255,255,0.75)',
        fontSize: 12,
        paddingRight: 8,
    },
    closeButton: {
        padding: 4,
    },
    tapZones: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 60,
        flexDirection: 'row',
        zIndex: 5,
    },
    tapLeft: {
        flex: 1,
    },
    tapRight: {
        flex: 2,
    },
    footer: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        padding: 16,
        backgroundColor: 'rgba(0,0,0,0.3)',
        zIndex: 10,
    },
    footerText: {
        color: 'white',
        fontSize: 13,
    },
    emptyText: {
        color: 'white',
        textAlign: 'center',
        marginTop: 200,
        fontSize: 16,
    },
})

const mapStateToProps = (store) => ({
    followingStories: store.storiesState.followingStories,
    viewedStories: store.storiesState.viewedStories,
})

const mapDispatchProps = (dispatch) =>
    bindActionCreators({ markStoryViewed }, dispatch)

export default connect(mapStateToProps, mapDispatchProps)(StoryViewer)
