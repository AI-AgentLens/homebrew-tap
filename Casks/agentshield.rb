cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1675"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1675/agentshield_0.2.1675_darwin_amd64.tar.gz"
      sha256 "d15fc1f1988c1c39228d1c4fb68362d7013983bea91ad316502aa8564253753e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1675/agentshield_0.2.1675_darwin_arm64.tar.gz"
      sha256 "abc623af86948fe46035ebb2ebb9e3509d9241fd8d5b8e04197d96e4420d625e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1675/agentshield_0.2.1675_linux_amd64.tar.gz"
      sha256 "757a0fa2589296c0b6647c7d6ddc31a38f4235366e70dff8b58f2bed839c7f46"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1675/agentshield_0.2.1675_linux_arm64.tar.gz"
      sha256 "f67ce9a0360d3842bb3407e98f5b523561e79c0dc3eee4b605b198786cf363e4"
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
