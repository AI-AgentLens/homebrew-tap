cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1106"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1106/agentshield_0.2.1106_darwin_amd64.tar.gz"
      sha256 "0461186a103d60e8b0c4c4b80a390a540d9c453e38cdefb892354827f0a2cb7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1106/agentshield_0.2.1106_darwin_arm64.tar.gz"
      sha256 "432c3da8cc0f5076cd91160a26ae85b41b5ceafa9c12ddd7ae4eb8eebbc69411"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1106/agentshield_0.2.1106_linux_amd64.tar.gz"
      sha256 "0322ccb36c448ef76741fc411ab4a8d56316562123e3634543ba07b827726daf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1106/agentshield_0.2.1106_linux_arm64.tar.gz"
      sha256 "365d8db23ce9f5deab61ea5e889aa96c37815ebc38c1ff2b80851b86285bbeae"
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
