cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.953"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.953/agentshield_0.2.953_darwin_amd64.tar.gz"
      sha256 "b64f5be403f9ed2e4900a711ed1f4a5f75b27bf2ac96b2d073a8f326cad45611"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.953/agentshield_0.2.953_darwin_arm64.tar.gz"
      sha256 "b20193bcd8fea92719a5c8f5620de3d008cd9bf40d41a3338c9db766cbc22aac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.953/agentshield_0.2.953_linux_amd64.tar.gz"
      sha256 "69f11cb5b4f19b6ebd3e36097ed7f7ff6d0545692481b165721ae3915333d6ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.953/agentshield_0.2.953_linux_arm64.tar.gz"
      sha256 "0d1b5981843051761614b5cf6d44c99178940efa74c446d6908fc518ee7494e9"
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
