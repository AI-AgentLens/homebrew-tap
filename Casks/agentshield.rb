cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.342"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.342/agentshield_0.2.342_darwin_amd64.tar.gz"
      sha256 "0e5b2769c4e812c1eebb6eaf9920b013f86caadc210e41f4d993414f42f3600b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.342/agentshield_0.2.342_darwin_arm64.tar.gz"
      sha256 "dafc42b11989cb9eb0fbff547773cb206eef7cee47ffdb923c00215628a7f5ca"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.342/agentshield_0.2.342_linux_amd64.tar.gz"
      sha256 "b5c4aaf1f26b6e9be7105975cc0e5f43afa7066e58eb8df300f85da454b8d6dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.342/agentshield_0.2.342_linux_arm64.tar.gz"
      sha256 "67b84b590cf55847056bc743e50ee8cbf07646a88763577248e4012bf0313668"
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
