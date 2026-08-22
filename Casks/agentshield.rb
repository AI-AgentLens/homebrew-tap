cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1923"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1923/agentshield_0.2.1923_darwin_amd64.tar.gz"
      sha256 "acde3c8bd534384798831b87d1f29c009cce83f00e9638634e35f79104b4aa31"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1923/agentshield_0.2.1923_darwin_arm64.tar.gz"
      sha256 "1c98e8f28ab5ca654b91ac9fa9cb42a87d57be0f358fdf4e3ad449368071e171"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1923/agentshield_0.2.1923_linux_amd64.tar.gz"
      sha256 "f3156452217a9fe51ac4757042f69a657e6f90777b8c8d58a7717150d2faefbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1923/agentshield_0.2.1923_linux_arm64.tar.gz"
      sha256 "027b550d02c658747075ed424a576ab60c87814aaf84f4b56659771b1ee93672"
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
