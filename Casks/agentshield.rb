cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.582"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.582/agentshield_0.2.582_darwin_amd64.tar.gz"
      sha256 "098a23182f1ae722813e4e15927f035d9064487dbb5d84245781d9cfec6c6c59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.582/agentshield_0.2.582_darwin_arm64.tar.gz"
      sha256 "a877ddfc73aab75765e3fd6b12bd2b226e9dc46828812aa144384b8c5d8cbeb9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.582/agentshield_0.2.582_linux_amd64.tar.gz"
      sha256 "04e1a3b05e751225a2fdc20d79ce221230f3a3edcf3601d32336584cd2ae05b9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.582/agentshield_0.2.582_linux_arm64.tar.gz"
      sha256 "5713ebe89ed3b0d17ecefc4959e4947cf986bd0e009dd12397969a7b8637094c"
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
