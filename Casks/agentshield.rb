cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.470"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.470/agentshield_0.2.470_darwin_amd64.tar.gz"
      sha256 "f0be9b0d1bc84e00e41f3d0ec271fa64ef3c3a67545b32593a85dcbb1764da18"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.470/agentshield_0.2.470_darwin_arm64.tar.gz"
      sha256 "a8862dc011293412ab8035c3acf07f6a0774edbe97e703a94509bfb4da38d8e7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.470/agentshield_0.2.470_linux_amd64.tar.gz"
      sha256 "e5c8d27664461404d564a78819d6122c997b0e77aa3ac8db7586e72d019223e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.470/agentshield_0.2.470_linux_arm64.tar.gz"
      sha256 "d44c71b777666ef915e3ed6477ed15f991f57513195aee6b49b92af339c7c42b"
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
