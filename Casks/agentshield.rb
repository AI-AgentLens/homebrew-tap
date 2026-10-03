cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2325"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2325/agentshield_0.2.2325_darwin_amd64.tar.gz"
      sha256 "5a5583776b7cd9b8359c368ea3d6e54895f750802706a44dfb65bc3f0f79c513"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2325/agentshield_0.2.2325_darwin_arm64.tar.gz"
      sha256 "c67cc275ea5bbc2eea7ad9f699c7835586e5289a36a97e3c0484eeee3a91befb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2325/agentshield_0.2.2325_linux_amd64.tar.gz"
      sha256 "c0a50637eeca30906306cc9f88f98f02624b6c31d13c3502e7ab33e8eced4586"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2325/agentshield_0.2.2325_linux_arm64.tar.gz"
      sha256 "fd5dedd6cf972362e3ec96f8ed03800b3f5e27b5c5bc9f8143ad7309b47c376c"
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
