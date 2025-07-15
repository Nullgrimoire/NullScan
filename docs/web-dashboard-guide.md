# 📊 NullScan Web Dashboard - Report Details Guide

## 🎯 How to Access Detailed Reports

### Method 1: Via Web Dashboard
1. **Start the Web Dashboard**
   ```bash
   nullscan --web-dashboard 8080
   ```

2. **Access the Dashboard**
   - Open your browser and go to: `http://localhost:8080/dashboard`

3. **View Recent Scans**
   - All your scans will be listed in the "Recent Scans" section
   - Each scan shows:
     - Scan name and status
     - Target information
     - Creation timestamp
     - Progress (ports scanned)

4. **Click on Any Scan**
   - Simply click on any scan item to view detailed results
   - You'll see the hint: "Click to view detailed results →"

### Method 2: Direct URL Access
If you know the scan ID, you can access the detailed report directly:
```
http://localhost:8080/scan/{scan-id}
```

### Method 3: API Access
You can also get scan details via the REST API:

```bash
# Get scan details
curl http://localhost:8080/api/scan/{scan-id}

# Get scan results
curl http://localhost:8080/api/scan/{scan-id}/results

# Export scan results
curl http://localhost:8080/api/scan/{scan-id}/export?format=json
```

## 🔍 What's in the Detailed Reports

### Scan Information Panel
- **Status**: Current scan status (Pending, Running, Completed, Failed)
- **Target**: The scanned target (IP, hostname, or CIDR)
- **Created**: When the scan was initiated
- **Progress**: Ports scanned vs total ports
- **Open Ports**: Number of open ports found
- **Vulnerabilities**: Total vulnerabilities detected

### Interactive Results Table
- **Host**: Target IP address
- **Port**: Port number scanned
- **Status**: Open or Closed
- **Service**: Detected service (HTTP, SSH, etc.)
- **Banner**: Service banner information
- **Response Time**: Connection response time
- **Vulnerabilities**: Number of vulnerabilities found per port

### Export Options
- **📄 Export JSON**: Download detailed results in JSON format
- **📊 Export CSV**: Download results in CSV format for spreadsheet analysis
- **🔄 Refresh**: Refresh the results page

## 🚀 Starting Scans

### Via Web Interface
1. Click "🚀 Start New Scan" on the dashboard
2. Fill in the scan configuration form:
   - **Target**: IP address, hostname, or CIDR notation
   - **Scan Name**: Custom name for the scan
   - **Port Selection**: Top 100, Top 1000, or Custom ports
   - **Options**: Banner grabbing, vulnerability checking, etc.
3. Click "🎯 Launch Scan"

### Via API
```bash
# PowerShell example
Invoke-RestMethod -Uri "http://localhost:8080/api/scan" -Method Post -ContentType "application/json" -Body '{
    "target": "192.168.1.0/24",
    "top100": true,
    "top1000": false,
    "ping_sweep": true,
    "banners": true,
    "vuln_check": true,
    "fast_mode": false,
    "name": "Network Discovery",
    "description": "Full network scan with banners"
}'
```

## 🎨 Dashboard Features

### Real-time Updates
- Dashboard auto-refreshes every 5 seconds
- Live progress tracking for running scans
- Status updates in real-time

### Professional Interface
- Dark theme optimized for red team workflows
- Responsive design for desktop and mobile
- Intuitive navigation and controls

### Team Collaboration
- Multiple users can access the same dashboard
- Shared scan results and history
- Professional reporting for clients

## 🔧 Advanced Usage

### Multiple Concurrent Scans
- Start multiple scans simultaneously
- Monitor all scans from a single dashboard
- Each scan runs independently

### Scan Management
- View all scans in chronological order
- Stop running scans if needed
- Clean history of completed scans

### Integration Options
- RESTful API for automation
- JSON/CSV export for further analysis
- Compatible with existing security workflows

---

**Pro Tip**: Bookmark `http://localhost:8080/dashboard` for quick access to your NullScan command center!
