cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.683"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.683/agentshield_0.2.683_darwin_amd64.tar.gz"
      sha256 "e1744078dfbcddbbdefd923e47e6b82be4f913da837ce5798c2f952d6ab8f89d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.683/agentshield_0.2.683_darwin_arm64.tar.gz"
      sha256 "f210e6852b02eac5019875537ea37bb3677b15c81706072b76fc64d484d22cc7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.683/agentshield_0.2.683_linux_amd64.tar.gz"
      sha256 "3b3a2084f2c851574c46e8988d745158052501cf953cbb7f9d30ed0c0eea621d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.683/agentshield_0.2.683_linux_arm64.tar.gz"
      sha256 "13acd3656f1d97f559e77681f167a1868614720e2d9a32a84a983f1d700c171e"
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
