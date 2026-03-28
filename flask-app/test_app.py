import pytest
from app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    return app.test_client()


def test_home(client):
    r = client.get('/')
    assert r.status_code == 200
    data = r.get_json()
    assert data['status'] == 'ok'
    assert 'Garavana' in data['message']


def test_health(client):
    r = client.get('/health')
    assert r.status_code == 200
    data = r.get_json()
    assert data['status'] == 'healthy'
    assert 'timestamp' in data


def test_metrics(client):
    r = client.get('/api/metrics')
    assert r.status_code == 200
    data = r.get_json()
    assert 'builds_today' in data
    assert 'success_rate' in data
    assert 'active_pods' in data
    assert 'nodes' in data
    assert len(data['nodes']) == 2


def test_dashboard(client):
    r = client.get('/dashboard')
    assert r.status_code == 200
    assert b'garavana' in r.data.lower()
