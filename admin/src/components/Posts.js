import React, { useEffect, useState } from 'react'

import firebase from 'firebase/app';
import 'firebase/firestore';

import { DataGrid } from '@material-ui/data-grid';
import Chip from '@material-ui/core/Chip';
import { Clear, Check } from '@material-ui/icons';
import Button from '@material-ui/core/Button';
import { useHistory } from "react-router-dom";

export default function Posts() {
    const [posts, setPosts] = useState([])
    const [loading, setLoading] = useState(false)

    useEffect(() => {
        fetchAllPosts();
    }, [])

    const fetchAllPosts = () => {
        setLoading(true);
        firebase.firestore()
            .collection("users")
            .get()
            .then((usersSnapshot) => {
                let allPosts = [];
                
                Promise.all(usersSnapshot.docs.map((userDoc) => {
                    return firebase.firestore()
                        .collection("posts")
                        .doc(userDoc.id)
                        .collection("userPosts")
                        .get()
                        .then((postsSnapshot) => {
                            postsSnapshot.docs.forEach((postDoc) => {
                                const data = postDoc.data();
                                allPosts.push({
                                    id: postDoc.id,
                                    userId: userDoc.id,
                                    ...data
                                });
                            });
                        });
                })).then(() => {
                    setPosts(allPosts);
                    setLoading(false);
                });
            });
    };

    const togglePromoted = (postId, userId, currentStatus) => {
        firebase.firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts')
            .doc(postId)
            .update({
                promoted: !currentStatus
            })
            .then(() => {
                fetchAllPosts();
            });
    };

    const deletePost = (postId, userId) => {
        firebase.firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts')
            .doc(postId)
            .delete()
            .then(() => {
                fetchAllPosts();
            });
    };

    const history = useHistory();

    const columns = [
        { field: 'id', headerName: 'Post ID', width: 250 },
        { field: 'userId', headerName: 'User ID', width: 250 },
        { 
            field: 'caption', 
            headerName: 'Caption', 
            width: 300,
            renderCell: (params) => (
                <div style={{ wordBreak: 'break-word', whiteSpace: 'normal' }}>
                    {params.value?.substring(0, 50) || 'No caption'}...
                </div>
            ),
        },
        {
            field: 'promoted', 
            headerName: 'Promoted', 
            width: 150,
            renderCell: (params) => (
                <div>
                    {params.row.promoted ?
                        <Chip
                            icon={<Check />}
                            label="Yes"
                            color="primary"
                            variant="outlined"
                        />
                        :
                        <Chip
                            icon={<Clear />}
                            label="No"
                            color="secondary"
                            variant="outlined"
                        />
                    }
                </div>
            ),
        },
        {
            field: 'toggle', 
            headerName: 'Toggle Promote', 
            width: 180,
            renderCell: (params) => (
                <div>
                    <Button 
                        variant="contained" 
                        color={params.row.promoted ? "secondary" : "primary"} 
                        onClick={() => togglePromoted(params.row.id, params.row.userId, params.row.promoted)}
                    >
                        {params.row.promoted ? 'Unpromote' : 'Promote'}
                    </Button>
                </div>
            ),
        },
        {
            field: 'delete', 
            headerName: 'Delete', 
            width: 120,
            renderCell: (params) => (
                <div>
                    <Button 
                        variant="contained" 
                        color="secondary" 
                        onClick={() => deletePost(params.row.id, params.row.userId)}
                    >
                        Delete
                    </Button>
                </div>
            ),
        },
    ];

    return (
        <div style={{ height: 600, width: '100%', marginTop: '100px', backgroundColor: 'white' }}>
            <DataGrid 
                rows={posts} 
                columns={columns} 
                pageSize={10}
                loading={loading}
                columns={columns.map((column) => ({
                    ...column,
                    disableClickEventBubbling: true,
                }))} 
            />
        </div>
    )
}
