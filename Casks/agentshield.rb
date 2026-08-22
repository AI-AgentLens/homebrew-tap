cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1926"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1926/agentshield_0.2.1926_darwin_amd64.tar.gz"
      sha256 "70b7baa11aead8b281dc95d39084c64f85f071e3472e89cc730709c83ef19336"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1926/agentshield_0.2.1926_darwin_arm64.tar.gz"
      sha256 "f8e5016593b3ccbb3c73808640c6195280380da85cccb7a5fd4b51cfc25e731c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1926/agentshield_0.2.1926_linux_amd64.tar.gz"
      sha256 "8cbdbe2bcb3e1492c1592cb475e9d3af0154b17dd9198fb664ab58627d6d54d5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1926/agentshield_0.2.1926_linux_arm64.tar.gz"
      sha256 "a3ac1ec0a8aed602ce3b1b5c4d81ea2ca702b6f8e470d3a51ee795588e1d1ea9"
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
