cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2443"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2443/agentshield_0.2.2443_darwin_amd64.tar.gz"
      sha256 "da66d0a22769caff5f9eb159f7e5956ca5ad230f723dcd979c3d58d9715c8d31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2443/agentshield_0.2.2443_darwin_arm64.tar.gz"
      sha256 "3b5d7559642a2b0a669ef03acbdbe15265424927644ecedbf5d07c9690e362b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2443/agentshield_0.2.2443_linux_amd64.tar.gz"
      sha256 "64c981e7ef95fa8de4842f38b4e89a145e8a13fcb18e7702a5f35425d321ae83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2443/agentshield_0.2.2443_linux_arm64.tar.gz"
      sha256 "b76f3e8fb8485ba778b47d90b1704c7b81af179fe856d4b6f94745d203729a9d"
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
