cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.139"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.139/agentshield_0.2.139_darwin_amd64.tar.gz"
      sha256 "5e1b4b92b8e8563b68078f59ebc7ef6db7d5ce24af4a3cbb0ff5ff0f676746ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.139/agentshield_0.2.139_darwin_arm64.tar.gz"
      sha256 "5d43a8028a57d013d9eda366b6552328e7c542765a4ab6c0c765a7b9a79bb878"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.139/agentshield_0.2.139_linux_amd64.tar.gz"
      sha256 "e773f314b4f40746fb8f3a55b3f8c9aa0ec22deea5c0d1f9ff037bbe33e100f8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.139/agentshield_0.2.139_linux_arm64.tar.gz"
      sha256 "ae1f4e7cbec0e46c6a494dd31b7364993e6910b30f78a2a8880c1ab4fc9db4fc"
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
