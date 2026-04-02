cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.338"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.338/agentshield_0.2.338_darwin_amd64.tar.gz"
      sha256 "d79cbf30ec72ae13bd76e5c3f0cb6ac4ecba404ff72178352c2e8d3887aa9b2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.338/agentshield_0.2.338_darwin_arm64.tar.gz"
      sha256 "8aecc6b17df9f4894eced26a019e9395bbd6b764a6a4895c6c80d7d8bb6d7edc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.338/agentshield_0.2.338_linux_amd64.tar.gz"
      sha256 "42cb4911e671be2ddc89ba8a80ae9b219debfbdb8977ff7d4771869b85e6e1f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.338/agentshield_0.2.338_linux_arm64.tar.gz"
      sha256 "962cc47b8bfb0dd84ebe08209d65996f7c1ff80d5486ff87d7245a20854518eb"
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
