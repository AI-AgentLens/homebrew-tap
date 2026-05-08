cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.916"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.916/agentshield_0.2.916_darwin_amd64.tar.gz"
      sha256 "1c2f96359998bf134bbfea6930b4d70a6e9165e2e03097238fbd1092911a333f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.916/agentshield_0.2.916_darwin_arm64.tar.gz"
      sha256 "631b7aac1f1d88154fa58c6d6b6d02f819180fb7ec41e443138e6e1975dd9f78"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.916/agentshield_0.2.916_linux_amd64.tar.gz"
      sha256 "40fb86df5e6effa57a4d92aca73742c3cb7b40a5bdabc76e3702d880969ea405"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.916/agentshield_0.2.916_linux_arm64.tar.gz"
      sha256 "d2a787bf1a705bc2eaadea95c5b1c6f7c262f6320a4115af66649c45889bc45a"
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
