cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.688"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.688/agentshield_0.2.688_darwin_amd64.tar.gz"
      sha256 "9b0a296102a2d71f7926491d4aa0a24af923b1ddef9827a46759ee6f445e7533"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.688/agentshield_0.2.688_darwin_arm64.tar.gz"
      sha256 "6e92d9b6115c8e1899b9a40a1b62974b58b73ee1a79920ee6c484892e44bbda0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.688/agentshield_0.2.688_linux_amd64.tar.gz"
      sha256 "8ba623470070649554d83021ba72bd35bff017d3ccd4d682406d5837a6418951"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.688/agentshield_0.2.688_linux_arm64.tar.gz"
      sha256 "c0d5f227e4f4c94db1450b02b65ffacff3d6f51719be58003a3231ce5fb09d6e"
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
