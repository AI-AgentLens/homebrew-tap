cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2085"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2085/agentshield_0.2.2085_darwin_amd64.tar.gz"
      sha256 "58a059074cc58b3e4cb6488a7fab0d078eefe14e3606f5895ac9e0939cee6983"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2085/agentshield_0.2.2085_darwin_arm64.tar.gz"
      sha256 "c239b0e3fa531ca7d34882857b854001276423a18b3e422153c504392ff522e6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2085/agentshield_0.2.2085_linux_amd64.tar.gz"
      sha256 "41a686a348bc2870db287097cb61b33739fef02bbaada5992fc4ca55b22c43eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2085/agentshield_0.2.2085_linux_arm64.tar.gz"
      sha256 "7546001fc295e6b031a3958d87487e659206499496ce10402fde31cc39b39df2"
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
