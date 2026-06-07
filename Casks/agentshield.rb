cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1238"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1238/agentshield_0.2.1238_darwin_amd64.tar.gz"
      sha256 "6ce9b869fd1eab9afca06aabb18d0a4c356e153e4b8c736de1a3815a45a7b06f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1238/agentshield_0.2.1238_darwin_arm64.tar.gz"
      sha256 "cc706e6707ff10d9698727c9b92d593f165411fde8218edc12d73ca0428fb999"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1238/agentshield_0.2.1238_linux_amd64.tar.gz"
      sha256 "03e361db2e7cd2c7535b1ed8205b7a09a25a4455abd1eb47f702ec4b092f2c8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1238/agentshield_0.2.1238_linux_arm64.tar.gz"
      sha256 "ebafa8d65c7586b84f1258dd28aae50c1b628265e2d7f46bd8ae1737ec3135d3"
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
