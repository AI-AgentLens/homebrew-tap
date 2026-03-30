cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.224"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.224/agentshield_0.2.224_darwin_amd64.tar.gz"
      sha256 "9e09f379898d317e5e8932eaa4cad980a99b6abdfd461e9cda45a0cc92ad1935"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.224/agentshield_0.2.224_darwin_arm64.tar.gz"
      sha256 "fe6ca45d3b6651a8d91ef7bbf46c5094bc6dab4999fc96fb55b210841ca2e879"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.224/agentshield_0.2.224_linux_amd64.tar.gz"
      sha256 "11df8e4d815728fc3c57788fa7461a43d71a05f7ccd8134ab675350b5bbc7ffb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.224/agentshield_0.2.224_linux_arm64.tar.gz"
      sha256 "1d912994cef8d73ba50aae26aecac06a138770b867d1d87f640d4fcced2ef8f8"
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
