cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.150"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.150/agentshield_0.2.150_darwin_amd64.tar.gz"
      sha256 "c40c837e73d2defa27364db487d816faed652bd8e917bce1e45539b484415604"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.150/agentshield_0.2.150_darwin_arm64.tar.gz"
      sha256 "f5fc28e36752e6ddce3b88a38123bec1d3eb2713564a839e9d8911ffdf5b8ff3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.150/agentshield_0.2.150_linux_amd64.tar.gz"
      sha256 "67cb3b9fa51d01da3b241293ef1b9ea81b1d56859ea5120bd207a7f2431c7744"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.150/agentshield_0.2.150_linux_arm64.tar.gz"
      sha256 "d422f6dc248f2c64bd06dab7384e7d5e88c1888c0242385a4fd509e9dc018368"
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
