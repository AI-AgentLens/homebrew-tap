cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1598"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1598/agentshield_0.2.1598_darwin_amd64.tar.gz"
      sha256 "f458447d77bb01aa306897f11e5e86993578b428f63d10b30a49fa3d77e9fe13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1598/agentshield_0.2.1598_darwin_arm64.tar.gz"
      sha256 "6e8c710d63aa2791e427f43658e22e6de9f9e534850acad4fa7c7e8ccf22469e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1598/agentshield_0.2.1598_linux_amd64.tar.gz"
      sha256 "35590143e734ac473aeada4d87d3032f37bf3c9ce7f8dfa0868ba984d109e4cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1598/agentshield_0.2.1598_linux_arm64.tar.gz"
      sha256 "b3c5605ccb2114e47cdee93c4e726bc55d48264d46188d4395e75334346bd87d"
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
