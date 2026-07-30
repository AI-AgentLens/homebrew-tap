cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1759"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1759/agentshield_0.2.1759_darwin_amd64.tar.gz"
      sha256 "baac9c7a64225b2b6b72a2cbfb0bf098bb6b5f64a3cadef5086f0c77a5db4647"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1759/agentshield_0.2.1759_darwin_arm64.tar.gz"
      sha256 "b1b0fd28bac57b6092ad555719b7bc1ecdce696d6beefd7463c2bc394157acd6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1759/agentshield_0.2.1759_linux_amd64.tar.gz"
      sha256 "50e91c63c45938cc1fde0249b37290e4f54d8dfc5f7e2f9be5f5262469eb3dc1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1759/agentshield_0.2.1759_linux_arm64.tar.gz"
      sha256 "e423097a39d1b49fb6f211fd30f499ada24d777ce8ec457013e74a14386de8b3"
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
