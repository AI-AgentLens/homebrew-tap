cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1871"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1871/agentshield_0.2.1871_darwin_amd64.tar.gz"
      sha256 "9f917bc4948e5d31ec6dd6e0c784a75a0f7ac6bb54270fa056d7da01f796dba3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1871/agentshield_0.2.1871_darwin_arm64.tar.gz"
      sha256 "e419d632861e813d547649915a744f14ed17ffca3e339bcd7fa7c8a508bd2e47"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1871/agentshield_0.2.1871_linux_amd64.tar.gz"
      sha256 "17f2804ef24c60689dbe884b542ea7d4ba4814e34f6c51fe5b65e02c39900a45"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1871/agentshield_0.2.1871_linux_arm64.tar.gz"
      sha256 "6dac19b6f24489a2fc84e29d0af3c3b59a67e1a3315acc6ae4290cbc43672a5a"
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
