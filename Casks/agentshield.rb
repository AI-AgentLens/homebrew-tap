cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.285"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.285/agentshield_0.2.285_darwin_amd64.tar.gz"
      sha256 "4de175f9c48ee44ccafd9b190d01c1b8e4a1607e16aad3c00f9eec71c9776cd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.285/agentshield_0.2.285_darwin_arm64.tar.gz"
      sha256 "5a1904d420aa264e6b4ca155f12defeb48d9d4d6b70ad1e23c19f959d035fd90"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.285/agentshield_0.2.285_linux_amd64.tar.gz"
      sha256 "714218f81a4591259b9c9323c850618bd48d500f9d07bfe9507c9642a5053d60"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.285/agentshield_0.2.285_linux_arm64.tar.gz"
      sha256 "dad2fafbc2a8c859f73208648b510e5156f7240e67793d0a344cd6e913379836"
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
