import { Feather } from '@expo/vector-icons'
import { useIsFocused } from '@react-navigation/native'
import { Audio } from 'expo-av'
import { Camera } from 'expo-camera'
import * as MediaLibrary from 'expo-media-library'
import React, { useEffect, useRef, useState } from 'react'
import {
    ActivityIndicator,
    Dimensions,
    FlatList,
    Image,
    ScrollView,
    StyleSheet,
    Text,
    TouchableOpacity,
    View,
} from 'react-native'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { uploadStory } from '../../../redux/actions/storiesActions'
import { container, utils } from '../../styles'

const WINDOW_HEIGHT = Dimensions.get('window').height
const WINDOW_WIDTH = Dimensions.get('window').width
const captureSize = Math.floor(WINDOW_HEIGHT * 0.09)
// Stories cap video at 15 seconds
const MAX_VIDEO_DURATION = 15

function CreateStoryCamera(props) {
    const [hasPermission, setHasPermission] = useState(null)
    const [cameraType, setCameraType] = useState(Camera.Constants.Type.back)
    const [isCameraReady, setIsCameraReady] = useState(false)
    const [isFlash, setIsFlash] = useState(false)
    const [isVideoRecording, setIsVideoRecording] = useState(false)
    const [captureMode, setCaptureMode] = useState(1) // 1 = photo, 0 = video
    const [showGallery, setShowGallery] = useState(true)
    const [galleryItems, setGalleryItems] = useState([])
    const [galleryPickedImage, setGalleryPickedImage] = useState(null)
    const [galleryScrollRef, setGalleryScrollRef] = useState(null)
    const [uploading, setUploading] = useState(false)
    const [uploadError, setUploadError] = useState(false)
    const cameraRef = useRef()
    const isFocused = useIsFocused()

    useEffect(() => {
        ;(async () => {
            const cameraPerms = await Camera.requestPermissionsAsync()
            const audioPerms = await Audio.requestPermissionsAsync()
            const galleryPerms = await MediaLibrary.requestPermissionsAsync()

            if (
                cameraPerms.status === 'granted' &&
                audioPerms.status === 'granted' &&
                galleryPerms.status === 'granted'
            ) {
                const photos = await MediaLibrary.getAssetsAsync({
                    sortBy: ['creationTime'],
                    mediaType: ['photo', 'video'],
                })
                setGalleryItems(photos)
                setGalleryPickedImage(photos.assets[0])
                setHasPermission(true)
            }
        })()
    }, [])

    const doUpload = async (uri, mediaType) => {
        setUploading(true)
        setUploadError(false)
        try {
            await props.uploadStory(uri, mediaType)
            props.navigation.goBack()
        } catch (_err) {
            setUploadError(true)
        } finally {
            setUploading(false)
        }
    }

    const takePicture = async () => {
        if (!cameraRef.current) return
        const data = await cameraRef.current.takePictureAsync({ quality: 0.5, skipProcessing: true })
        if (data.uri) {
            await doUpload(data.uri, 1)
        }
    }

    const recordVideo = async () => {
        if (!cameraRef.current) return
        try {
            const options = {
                maxDuration: MAX_VIDEO_DURATION,
                quality: Camera.Constants.VideoQuality['480p'],
            }
            const videoRecordPromise = cameraRef.current.recordAsync(options)
            if (videoRecordPromise) {
                setIsVideoRecording(true)
                const data = await videoRecordPromise
                setIsVideoRecording(false)
                await doUpload(data.uri, 0)
            }
        } catch (_error) {
            setIsVideoRecording(false)
        }
    }

    const stopVideoRecording = () => {
        if (cameraRef.current) {
            setIsVideoRecording(false)
            cameraRef.current.stopRecording()
        }
    }

    const switchCamera = () => {
        setCameraType((prev) =>
            prev === Camera.Constants.Type.back
                ? Camera.Constants.Type.front
                : Camera.Constants.Type.back
        )
    }

    const handleGalleryPick = async () => {
        if (!galleryPickedImage) return
        const mediaType = galleryPickedImage.mediaType === 'video' ? 0 : 1
        const loaded = await MediaLibrary.getAssetInfoAsync(galleryPickedImage)
        await doUpload(loaded.localUri, mediaType)
    }

    if (hasPermission === null) return <View />
    if (hasPermission === false) {
        return (
            <View style={[container.container, utils.justifyCenter, utils.alignItemsCenter]}>
                <Text>No access to camera</Text>
            </View>
        )
    }

    if (uploading) {
        return (
            <View style={[container.container, utils.justifyCenter, utils.alignItemsCenter]}>
                <ActivityIndicator size="large" />
                <Text style={{ paddingTop: 12, fontWeight: '600' }}>Posting story…</Text>
            </View>
        )
    }

    if (uploadError) {
        return (
            <View style={[container.container, utils.justifyCenter, utils.alignItemsCenter]}>
                <Text style={{ color: 'red', paddingBottom: 16 }}>Something went wrong. Please try again.</Text>
                <TouchableOpacity
                    style={styles.retryButton}
                    onPress={() => setUploadError(false)}>
                    <Text style={{ color: 'white', fontWeight: '600' }}>Retry</Text>
                </TouchableOpacity>
            </View>
        )
    }

    const renderCapture = () => (
        <View>
            <View style={styles.controlRow}>
                <TouchableOpacity disabled={!isCameraReady} onPress={() => setIsFlash(!isFlash)}>
                    <Feather style={utils.margin15} name="zap" size={25} color="black" />
                </TouchableOpacity>
                <TouchableOpacity disabled={!isCameraReady} onPress={switchCamera}>
                    <Feather style={utils.margin15} name="rotate-cw" size={25} color="black" />
                </TouchableOpacity>

                {captureMode === 0 ? (
                    <TouchableOpacity
                        activeOpacity={0.7}
                        disabled={!isCameraReady}
                        onLongPress={recordVideo}
                        onPressOut={stopVideoRecording}
                        style={[styles.captureBtn, isVideoRecording && styles.captureBtnActive]}
                    />
                ) : (
                    <TouchableOpacity
                        activeOpacity={0.7}
                        disabled={!isCameraReady}
                        onPress={takePicture}
                        style={styles.captureBtnPhoto}
                    />
                )}

                <TouchableOpacity
                    disabled={!isCameraReady}
                    onPress={() => setCaptureMode(captureMode === 1 ? 0 : 1)}>
                    <Feather
                        style={utils.margin15}
                        name={captureMode === 0 ? 'camera' : 'video'}
                        size={25}
                        color="black"
                    />
                </TouchableOpacity>
                <TouchableOpacity onPress={() => setShowGallery(true)}>
                    <Feather style={utils.margin15} name="image" size={25} color="black" />
                </TouchableOpacity>
            </View>
            {captureMode === 0 && (
                <Text style={styles.videoHint}>Hold for video — max {MAX_VIDEO_DURATION}s</Text>
            )}
        </View>
    )

    if (showGallery) {
        return (
            <ScrollView
                ref={(ref) => setGalleryScrollRef(ref)}
                style={[container.container, utils.backgroundWhite]}>
                <View style={{ aspectRatio: 1 / 1, height: WINDOW_WIDTH }}>
                    {galleryPickedImage && (
                        <Image
                            style={{ aspectRatio: 1 / 1, height: WINDOW_WIDTH }}
                            source={{ uri: galleryPickedImage.uri }}
                        />
                    )}
                </View>
                <View style={styles.galleryActions}>
                    <TouchableOpacity
                        style={styles.continueBtn}
                        onPress={handleGalleryPick}>
                        <Text style={styles.continueBtnText}>Post as Story</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={styles.cameraToggleBtn}
                        onPress={() => setShowGallery(false)}>
                        <Feather style={{ padding: 10 }} name="camera" size={20} color="white" />
                    </TouchableOpacity>
                </View>
                <View style={[{ flex: 1 }, utils.borderTopGray]}>
                    <FlatList
                        numColumns={3}
                        horizontal={false}
                        data={galleryItems.assets}
                        contentContainerStyle={{ flexGrow: 1 }}
                        keyExtractor={(item) => item.id}
                        renderItem={({ item }) => (
                            <TouchableOpacity
                                style={[container.containerImage, utils.borderWhite]}
                                onPress={() => {
                                    galleryScrollRef &&
                                        galleryScrollRef.scrollTo({ x: 0, y: 0, animated: true })
                                    setGalleryPickedImage(item)
                                }}>
                                <Image
                                    style={container.image}
                                    source={{ uri: item.uri }}
                                />
                            </TouchableOpacity>
                        )}
                    />
                </View>
            </ScrollView>
        )
    }

    return (
        <View style={{ flex: 1, flexDirection: 'column', backgroundColor: 'white' }}>
            <View style={{ aspectRatio: 1 / 1, height: WINDOW_WIDTH }}>
                {isFocused && (
                    <Camera
                        ref={cameraRef}
                        style={{ aspectRatio: 1 / 1, height: WINDOW_WIDTH }}
                        type={cameraType}
                        flashMode={
                            isFlash
                                ? Camera.Constants.FlashMode.torch
                                : Camera.Constants.FlashMode.off
                        }
                        ratio="1:1"
                        onCameraReady={() => setIsCameraReady(true)}
                    />
                )}
            </View>
            <View style={{ flexDirection: 'row', alignItems: 'center', flex: 1 }}>
                <View>{renderCapture()}</View>
            </View>
        </View>
    )
}

const styles = StyleSheet.create({
    controlRow: {
        justifyContent: 'space-evenly',
        width: '100%',
        alignItems: 'center',
        flexDirection: 'row',
        backgroundColor: 'white',
    },
    captureBtn: {
        backgroundColor: 'red',
        height: captureSize,
        width: captureSize,
        borderRadius: captureSize / 2,
        marginHorizontal: 31,
    },
    captureBtnActive: {
        backgroundColor: '#cc0000',
        transform: [{ scale: 0.9 }],
    },
    captureBtnPhoto: {
        borderWidth: 6,
        borderColor: 'gray',
        backgroundColor: 'white',
        height: captureSize,
        width: captureSize,
        borderRadius: captureSize / 2,
        marginHorizontal: 31,
    },
    videoHint: {
        textAlign: 'center',
        color: 'gray',
        fontSize: 12,
        paddingBottom: 6,
    },
    galleryActions: {
        justifyContent: 'flex-end',
        alignItems: 'center',
        paddingRight: 20,
        paddingVertical: 10,
        flexDirection: 'row',
    },
    continueBtn: {
        alignItems: 'center',
        backgroundColor: 'gray',
        paddingHorizontal: 20,
        paddingVertical: 10,
        marginRight: 15,
        borderRadius: 50,
        borderWidth: 1,
        borderColor: 'black',
    },
    continueBtnText: {
        fontWeight: 'bold',
        color: 'white',
        paddingBottom: 1,
    },
    cameraToggleBtn: {
        alignItems: 'center',
        backgroundColor: 'gray',
        borderRadius: 50,
        borderWidth: 1,
        borderColor: 'black',
    },
    retryButton: {
        backgroundColor: 'gray',
        paddingHorizontal: 24,
        paddingVertical: 10,
        borderRadius: 8,
    },
})

const mapStateToProps = (_store) => ({})
const mapDispatchProps = (dispatch) => bindActionCreators({ uploadStory }, dispatch)

export default connect(mapStateToProps, mapDispatchProps)(CreateStoryCamera)
