cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1622"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1622/agentshield_0.2.1622_darwin_amd64.tar.gz"
      sha256 "971ebbcb9d7ade82d844ed482c63b063f5e8ac80db1824fe34735a6e1fb7a338"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1622/agentshield_0.2.1622_darwin_arm64.tar.gz"
      sha256 "e7c986dee39d9111052876b1c1ad6a53c7b0a03739d4a490f47484a59a35bb77"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1622/agentshield_0.2.1622_linux_amd64.tar.gz"
      sha256 "c6b760b15e499c1e5c8dd019fc4bfc6568988b9919c41a7056ed55e9f8f8ffa2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1622/agentshield_0.2.1622_linux_arm64.tar.gz"
      sha256 "3496aadf4e9089d1badb45c585910cc6615d97d38c08e930aa2f8ec6a2126ea3"
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
