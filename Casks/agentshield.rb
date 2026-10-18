cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2462"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2462/agentshield_0.2.2462_darwin_amd64.tar.gz"
      sha256 "bef961e96f0ecd24292e846fd7bb70ee1316e031c70c0206285c0be90792dc35"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2462/agentshield_0.2.2462_darwin_arm64.tar.gz"
      sha256 "3282bc27d3b02df115d526505f9d141c05c368517dd559f152aa102beab7ae78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2462/agentshield_0.2.2462_linux_amd64.tar.gz"
      sha256 "a0c5bfa8345c40b4e6c791db0d03f394d48611dfbdd7f760d999295ecf0ccd8e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2462/agentshield_0.2.2462_linux_arm64.tar.gz"
      sha256 "81238e318afbc2ffa041cb4f5bb9ac48f3e3ccadb4963858302fd9bc9fcbffba"
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
