cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1123"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1123/agentshield_0.2.1123_darwin_amd64.tar.gz"
      sha256 "984d95e2bb270ac5d8b269072e1b358239141d0f6baf36f71afc84bc19a572a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1123/agentshield_0.2.1123_darwin_arm64.tar.gz"
      sha256 "3166e898be9a30d25446f4ce67b1a78104c11cf8fe2a39de5971584dec33054c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1123/agentshield_0.2.1123_linux_amd64.tar.gz"
      sha256 "727d1d7290a0202b41f0968a53a566c7cc1dd69b2e3812aed88ff31e807cd3c0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1123/agentshield_0.2.1123_linux_arm64.tar.gz"
      sha256 "1baa7b72fbb8f0cce4bb24853ef556e05b53d1886285f9f852817792efc5f9db"
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
