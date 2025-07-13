use crate::presets::{get_top_ports, PortPreset};

#[cfg(test)]
#[allow(clippy::module_inception)]
mod tests {
    use super::*;

    #[test]
    fn test_top_100_ports() {
        let ports = get_top_ports(PortPreset::Top100);
        assert_eq!(ports.len(), 100);
        assert!(ports.contains(&80));
        assert!(ports.contains(&443));
        assert!(ports.contains(&22));
        assert!(ports.contains(&21));
    }

    #[test]
    fn test_top_1000_ports() {
        let ports = get_top_ports(PortPreset::Top1000);
        assert!(ports.len() >= 900); // Allow some flexibility in count
        assert!(ports.contains(&80));
        assert!(ports.contains(&443));
        assert!(ports.contains(&22));
        assert!(ports.contains(&21));

        // Ensure ports are sorted and unique
        let mut sorted_ports = ports.clone();
        sorted_ports.sort();
        sorted_ports.dedup();
        assert_eq!(ports, sorted_ports);
    }

    #[test]
    fn test_top_100_is_subset_of_top_1000() {
        let top_100 = get_top_ports(PortPreset::Top100);
        let top_1000 = get_top_ports(PortPreset::Top1000);

        for port in top_100 {
            assert!(
                top_1000.contains(&port),
                "Port {port} should be in top 1000"
            );
        }
    }
}
