cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1969"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1969/agentshield_0.2.1969_darwin_amd64.tar.gz"
      sha256 "8e5da2194a363c3db766a4cd6e475b2d654b801c17a39f0962a4242929ac9e39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1969/agentshield_0.2.1969_darwin_arm64.tar.gz"
      sha256 "428d6409eecd0d7ff0edd4a14699a10d6ede6f37c61748d0b617a95fe7558d6b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1969/agentshield_0.2.1969_linux_amd64.tar.gz"
      sha256 "1c17d8bec5792a6d08289b695479f90f604c2c98f31711f338712c558d074f93"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1969/agentshield_0.2.1969_linux_arm64.tar.gz"
      sha256 "d5d99290233bb0995ebcfea47c4dc1bac12fdccba1e532d765913c08b790d721"
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
