cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1664"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1664/agentshield_0.2.1664_darwin_amd64.tar.gz"
      sha256 "35102b0b5207e9b06e2db49af325494f64765208267c0f51fd106b80cf7994ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1664/agentshield_0.2.1664_darwin_arm64.tar.gz"
      sha256 "40648e2fad11c31d4680d75c368b9ca03b952c86bcf4f4e0fb31e738c13aaddb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1664/agentshield_0.2.1664_linux_amd64.tar.gz"
      sha256 "c6cea8892395eaf12241f75ce14ce5cde09f4ab18440030b1926d4c4a0c259a4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1664/agentshield_0.2.1664_linux_arm64.tar.gz"
      sha256 "550adfcbfa3ca3217db9af160d244f51f353b6695d5611c1296e8458d6efd88c"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
