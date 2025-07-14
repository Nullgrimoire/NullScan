# Banner Grabbing & Service Detection Deep Dive

## Overview

NullScan's banner grabbing system implements intelligent, protocol-specific service detection with confidence scoring and fallback mechanisms. This system goes beyond simple banner collection to provide accurate service identification and version detection.

## Architecture Overview

### Core Components

- **Protocol-Specific Probes** - Tailored detection for major protocols
- **Confidence Scoring System** - Reliability assessment for detections
- **Fallback Mechanisms** - Multiple detection strategies per service
- **Timeout Management** - Optimized timeouts per protocol type
- **Enhanced Banner Analysis** - Version extraction and service fingerprinting

## Protocol Detection Strategies

### 1. SSH Detection (Port 22)

**Strategy**: SSH version string analysis with protocol negotiation

```rust
// SSH detection reads version string immediately
// Format: "SSH-2.0-ServiceName_Version Comments"
```

**Detection Features**:

- **Version Extraction** - Identifies SSH protocol version (1.x/2.x)
- **Service Identification** - Detects OpenSSH, Dropbear, libssh variants
- **Implementation Details** - Server software version and build info
- **Security Features** - Supported encryption and authentication methods

**Example Output**:
```
SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.1
SSH-2.0-Dropbear_2020.81
SSH-1.99-Cisco_1.25
```

### 2. TLS/SSL Detection (Ports 443, 993, 995, 8443)

**Strategy**: TLS handshake analysis with certificate inspection

**Detection Features**:

- **Protocol Versions** - TLS 1.0/1.1/1.2/1.3 support detection
- **Cipher Suite Analysis** - Supported encryption algorithms
- **Certificate Information** - Subject, issuer, validity periods
- **Server Software** - Web server identification via TLS extensions

**Common Detections**:
```
TLS 1.3 - Apache/2.4.52 (Ubuntu)
TLS 1.2 - nginx/1.20.1
TLS 1.3 - Microsoft-IIS/10.0
```

### 3. HTTP Detection (Ports 80, 8080, 8000, 3000)

**Strategy**: HTTP request/response analysis with header inspection

**Detection Features**:

- **Server Headers** - Web server identification and version
- **Framework Detection** - Application framework fingerprinting
- **Technology Stack** - Programming language and runtime detection
- **Security Headers** - Security configuration analysis

**Example Detection**:
```
HTTP/1.1 200 OK
Server: Apache/2.4.52 (Ubuntu)
X-Powered-By: PHP/8.1.2
```

### 4. Database Detection

#### MySQL (Port 3306)
**Strategy**: MySQL greeting packet analysis

```
MySQL 8.0.32-0ubuntu0.22.04.2 - Protocol version 10
```

#### PostgreSQL (Port 5432)
**Strategy**: PostgreSQL startup message analysis

```
PostgreSQL 14.7 (Ubuntu 14.7-0ubuntu0.22.04.1)
```

#### MongoDB (Port 27017)
**Strategy**: MongoDB hello command response

```
MongoDB 6.0.5 - WiredTiger storage engine
```

### 5. Email Service Detection

#### SMTP (Ports 25, 587, 465)
**Strategy**: SMTP greeting and EHLO response analysis

```
220 mail.example.com ESMTP Postfix (Ubuntu)
250-mail.example.com
250-PIPELINING
250-SIZE 10240000
250 STARTTLS
```

#### POP3 (Port 110)
**Strategy**: POP3 greeting message analysis

```
+OK Dovecot (Ubuntu) ready.
```

#### IMAP (Port 143)
**Strategy**: IMAP capability response analysis

```
* OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE STARTTLS] Dovecot (Ubuntu) ready.
```

## Advanced Detection Features

### 1. Confidence Scoring

Each detection includes a confidence score based on multiple factors:

**High Confidence (90-100%)**:
- Complete protocol handshake successful
- Version string explicitly provided
- Protocol-specific commands responded correctly

**Medium Confidence (60-89%)**:
- Partial protocol response
- Banner contains service indicators
- Port matches expected service

**Low Confidence (30-59%)**:
- Generic response pattern
- Port-based assumption only
- Incomplete protocol negotiation

### 2. Fallback Detection Chain

When primary detection fails, the system employs cascading fallback strategies:

1. **Protocol-Specific Probe** - Tailored to expected service
2. **Generic Banner Grab** - Simple socket read operation
3. **Port-Based Assumption** - Common service for port number
4. **Connection Analysis** - Behavior-based detection

### 3. Version Extraction

Advanced regex patterns extract detailed version information:

```rust
// SSH version extraction
let ssh_pattern = r"SSH-(\d+\.\d+)-(.+)";

// HTTP server extraction
let server_pattern = r"Server:\s*([^\r\n]+)";

// Database version extraction
let mysql_pattern = r"(\d+\.\d+\.\d+)";
```

## Performance Optimizations

### 1. Timeout Strategies

**Protocol-Aware Timeouts**:
- **Fast Protocols** (SSH, HTTP): 2-3 seconds
- **Slower Protocols** (SMTP, databases): 5-7 seconds
- **Complex Handshakes** (TLS): 8-10 seconds

### 2. Connection Reuse

For protocols supporting multiple commands, connections are reused:
- **SMTP**: EHLO followed by additional commands
- **HTTP**: Multiple requests on persistent connections
- **Databases**: Authentication followed by version queries

### 3. Parallel Processing

Banner grabbing operates in parallel with port scanning:
- **Concurrent Probes** - Multiple protocols tested simultaneously
- **Async Operations** - Non-blocking I/O for all network operations
- **Resource Management** - Controlled concurrency to prevent overwhelming targets

## Custom Protocol Support

### Adding New Protocols

To add support for a new protocol, implement the following pattern:

```rust
async fn probe_custom_service(&self, stream: &mut TcpStream, timeout: Duration) -> Result<ProbeResult> {
    // 1. Send protocol-specific probe
    let probe_data = b"CUSTOM_PROTOCOL_HELLO\r\n";
    timeout(timeout, stream.write_all(probe_data)).await??;

    // 2. Read response
    let mut buffer = vec![0; 1024];
    let bytes_read = timeout(timeout, stream.read(&mut buffer)).await??;

    // 3. Parse response
    let response = String::from_utf8_lossy(&buffer[..bytes_read]);

    // 4. Extract service information
    if response.contains("CUSTOM_SERVICE") {
        Ok(ProbeResult {
            service: "Custom Service".to_string(),
            banner: response.trim().to_string(),
        })
    } else {
        Err(anyhow::anyhow!("Not a custom service"))
    }
}
```

### Protocol Registration

Add the new protocol to the main detection method:

```rust
match port {
    22 => self.probe_ssh(stream, timeout_duration).await,
    443 | 993 | 995 | 8443 => self.probe_tls(stream, timeout_duration).await,
    // ... existing protocols
    9999 => self.probe_custom_service(stream, timeout_duration).await, // New protocol
    _ => self.simple_banner_grab(stream, port).await,
}
```

## Usage Examples

### Basic Banner Grabbing
```bash
# Enable banner grabbing for common ports
nullscan --target 192.168.1.100 --top100 --banners
```

### Service-Specific Scanning
```bash
# Focus on web services
nullscan --target example.com --ports 80,443,8080,8443 --banners

# Database service discovery
nullscan --target db-server --ports 3306,5432,27017,1433 --banners

# Email service enumeration
nullscan --target mail-server --ports 25,110,143,993,995 --banners
```

### Advanced Configuration
```bash
# High-timeout for slow services
nullscan --target slow-network --top100 --banners --timeout 10000

# Combine with vulnerability checking
nullscan --target target --top1000 --banners --vuln-check
```

## Output Formats

### Terminal Output
```
192.168.1.100:22   open    SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.1
192.168.1.100:80   open    HTTP/1.1 - Apache/2.4.52 (Ubuntu)
192.168.1.100:443  open    TLS 1.3 - Apache/2.4.52 (Ubuntu)
```

### JSON Export
```json
{
  "host": "192.168.1.100",
  "port": 22,
  "status": "open",
  "banner": "SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.1",
  "service": "SSH",
  "confidence": 95
}
```

### HTML Report
Professional HTML output with:
- **Sortable Tables** - Click column headers to sort
- **Service Grouping** - Group by service type
- **Banner Expansion** - Click to view full banner details
- **Export Options** - Copy individual results to clipboard

## Troubleshooting

### Common Issues

#### Empty Banners
**Cause**: Service doesn't provide immediate banner
**Solution**: Some services require specific commands first

#### Timeout Errors
**Cause**: Service takes too long to respond
**Solution**: Increase timeout with `--timeout` parameter

#### Incomplete Detection
**Cause**: Service uses non-standard responses
**Solution**: Examine raw banner data and add custom patterns

#### Connection Refused
**Cause**: Service has connection limits or filtering
**Solution**: Reduce concurrency or scan from different source

### Debugging Banner Grabbing

```bash
# Enable verbose output to see detection process
nullscan --target host --ports 80 --banners --verbose

# Test specific protocols
nullscan --target ssh-server --ports 22 --banners --timeout 10000
```

### Manual Banner Testing

```bash
# Test banner grabbing manually
telnet target 22
nc target 80
openssl s_client -connect target:443
```

## Security Considerations

### Detection Evasion

Some security tools attempt to detect banner grabbing:
- **IDS/IPS Systems** - May flag multiple connection attempts
- **Honeypots** - May provide false banner information
- **Rate Limiting** - Services may limit connection frequency

### Responsible Usage

- **Authorization** - Only scan systems you own or have permission to test
- **Rate Limiting** - Use appropriate concurrency settings
- **Data Handling** - Secure handling of collected banner information
- **Logging** - Be aware that banner grabbing activities are logged

## Future Enhancements

### Planned Features

- **Machine Learning** - AI-based service classification
- **Behavioral Analysis** - Service identification through behavior patterns
- **Protocol Fuzzing** - Advanced protocol probing techniques
- **Signature Database** - Centralized service signature repository

### Community Contributions

- **New Protocols** - Adding support for additional services
- **Signature Improvements** - Enhanced detection patterns
- **Performance Optimizations** - Faster detection algorithms
- **Documentation** - Protocol-specific guides and examples

---

**Banner Grabbing** - Professional service identification for security assessment.
Built for accuracy, performance, and extensibility.
