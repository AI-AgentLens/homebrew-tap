cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2210"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2210/agentshield_0.2.2210_darwin_amd64.tar.gz"
      sha256 "c48da307e072d4a3206e61753e5077d011d240aaff28f746126aead6b3a1ddb4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2210/agentshield_0.2.2210_darwin_arm64.tar.gz"
      sha256 "5b24928852a5ac0b2e027a6ae212aa06731932476967f08055d23a9687fd2d06"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2210/agentshield_0.2.2210_linux_amd64.tar.gz"
      sha256 "4b93b87f05a8673303d438af8269cfbb1824e05919905fa2a6c9c01027031799"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2210/agentshield_0.2.2210_linux_arm64.tar.gz"
      sha256 "6637300e9c794ec23b2350c3f7ae06785ff619a19687db8c75541200607c6574"
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
