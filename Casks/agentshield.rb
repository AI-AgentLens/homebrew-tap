cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.437"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.437/agentshield_0.2.437_darwin_amd64.tar.gz"
      sha256 "f695616bfc50403dd730c58083ef7d930edd8468dee1845f0ff2a74fd96f96bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.437/agentshield_0.2.437_darwin_arm64.tar.gz"
      sha256 "cecfa3433ea9bdd253ed2ddf31bf9ac641ade61d7d09bba71623a501d5df87a1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.437/agentshield_0.2.437_linux_amd64.tar.gz"
      sha256 "174c776f340f1d0e8174c3914b84b21ca8166909711df4a3df24013e552218f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.437/agentshield_0.2.437_linux_arm64.tar.gz"
      sha256 "36f2f4390246f0ee07977f511f6e02e78aebd554eae39ac1ed7281a88f8456ab"
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
