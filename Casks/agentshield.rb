cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1698"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1698/agentshield_0.2.1698_darwin_amd64.tar.gz"
      sha256 "1a17ac43df9eed01cd02c39acb7fe8b3b1b6cfd0d1bfa138b95545471393bd7b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1698/agentshield_0.2.1698_darwin_arm64.tar.gz"
      sha256 "d6ca0e99c3a617cf7f626ce5ce9fe13545ed614f8935282f4bea41bd1b3f2fcc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1698/agentshield_0.2.1698_linux_amd64.tar.gz"
      sha256 "a20d9776907d6059ba6455bbca56b26e68f92ff43cb15c3fccf96390071e01dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1698/agentshield_0.2.1698_linux_arm64.tar.gz"
      sha256 "91251eb08ecf255761a3ef020335da557dfca2a12cf6e3f9275a5c4c34c66e93"
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
