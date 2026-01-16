import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Typography,
  Button,
  Box,
  Card,
  CardContent,
  Avatar,
  Grid,
  CircularProgress,
  Chip,
  Divider,
  Alert,
} from '@mui/material';
import { Logout, Person, Email, VerifiedUser, CalendarToday, Security } from '@mui/icons-material';
import { toast } from 'react-toastify';
import { userAPI } from '../services/api';
import { storage } from '../utils/storage';
import { escapeHtml } from '../utils/security';

const Dashboard = () => {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchUser = useCallback(async () => {
    try {
      setError(null);
      const response = await userAPI.getCurrentUser();
      setUser(response.data);
    } catch (error) {
      const errorMessage = error.response?.data?.message || 'Failed to load user data';
      setError(errorMessage);
      toast.error(errorMessage);
      
      // Only redirect if it's a 401 (unauthorized)
      if (error.response?.status === 401) {
        setTimeout(() => navigate('/login'), 2000);
      }
    } finally {
      setLoading(false);
    }
  }, [navigate]);

  useEffect(() => {
    fetchUser();
  }, [fetchUser]);

  const handleLogout = () => {
    storage.removeItem('accessToken');
    storage.removeItem('refreshToken');
    toast.success('Logged out successfully');
    navigate('/login');
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      });
    } catch (e) {
      return dateString;
    }
  };

  if (loading) {
    return (
      <Container maxWidth="md">
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: '60vh',
          }}
        >
          <CircularProgress size={60} />
          <Typography variant="body1" sx={{ mt: 2 }}>
            Loading your dashboard...
          </Typography>
        </Box>
      </Container>
    );
  }

  if (error && !user) {
    return (
      <Container maxWidth="md">
        <Box sx={{ mt: 4 }}>
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
          <Button variant="contained" onClick={fetchUser}>
            Retry
          </Button>
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="md">
      <Box sx={{ mt: 4, mb: 4 }}>
        <Paper elevation={3} sx={{ padding: 4 }}>
          {/* Header */}
          <Box
            sx={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              mb: 3,
              flexWrap: 'wrap',
              gap: 2,
            }}
          >
            <Typography variant="h4" component="h1" sx={{ fontWeight: 600 }}>
              Dashboard
            </Typography>
            <Button
              variant="outlined"
              color="error"
              startIcon={<Logout />}
              onClick={handleLogout}
              sx={{ minWidth: 120 }}
            >
              Logout
            </Button>
          </Box>

          <Divider sx={{ mb: 3 }} />

          {user && (
            <Grid container spacing={3}>
              {/* User Profile Card */}
              <Grid item xs={12}>
                <Card elevation={2}>
                  <CardContent>
                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                      <Avatar
                        sx={{
                          bgcolor: 'primary.main',
                          width: 64,
                          height: 64,
                          mr: 2,
                          fontSize: '2rem',
                        }}
                      >
                        {user.username?.charAt(0).toUpperCase() || <Person />}
                      </Avatar>
                      <Box>
                        <Typography variant="h5" sx={{ fontWeight: 600 }}>
                          Welcome, {escapeHtml(user.username)}!
                        </Typography>
                        <Chip
                          icon={<VerifiedUser />}
                          label={user.isVerified ? 'Verified' : 'Unverified'}
                          color={user.isVerified ? 'success' : 'warning'}
                          size="small"
                          sx={{ mt: 1 }}
                        />
                      </Box>
                    </Box>

                    <Divider sx={{ my: 2 }} />

                    {/* User Details */}
                    <Grid container spacing={2}>
                      <Grid item xs={12} sm={6}>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                          <Email sx={{ mr: 1, color: 'text.secondary' }} />
                          <Box>
                            <Typography variant="caption" color="text.secondary">
                              Email Address
                            </Typography>
                            <Typography variant="body1" sx={{ fontWeight: 500 }}>
                              {escapeHtml(user.email)}
                            </Typography>
                          </Box>
                        </Box>
                      </Grid>

                      <Grid item xs={12} sm={6}>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                          <Security sx={{ mr: 1, color: 'text.secondary' }} />
                          <Box>
                            <Typography variant="caption" color="text.secondary">
                              Role
                            </Typography>
                            <Typography variant="body1" sx={{ fontWeight: 500 }}>
                              {escapeHtml(user.role)}
                            </Typography>
                          </Box>
                        </Box>
                      </Grid>

                      <Grid item xs={12} sm={6}>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                          <VerifiedUser sx={{ mr: 1, color: 'text.secondary' }} />
                          <Box>
                            <Typography variant="caption" color="text.secondary">
                              Verification Status
                            </Typography>
                            <Typography variant="body1" sx={{ fontWeight: 500 }}>
                              {user.isVerified ? 'Verified ✓' : 'Not Verified ✗'}
                            </Typography>
                          </Box>
                        </Box>
                      </Grid>

                      <Grid item xs={12} sm={6}>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                          <CalendarToday sx={{ mr: 1, color: 'text.secondary' }} />
                          <Box>
                            <Typography variant="caption" color="text.secondary">
                              Member Since
                            </Typography>
                            <Typography variant="body1" sx={{ fontWeight: 500 }}>
                              {formatDate(user.createdAt)}
                            </Typography>
                          </Box>
                        </Box>
                      </Grid>
                    </Grid>
                  </CardContent>
                </Card>
              </Grid>

              {/* Additional Info Card */}
              {!user.isVerified && (
                <Grid item xs={12}>
                  <Alert severity="warning">
                    Please verify your email address to access all features.
                  </Alert>
                </Grid>
              )}
            </Grid>
          )}
        </Paper>
      </Box>
    </Container>
  );
};

export default Dashboard;
