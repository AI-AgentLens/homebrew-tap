cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1517"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1517/agentshield_0.2.1517_darwin_amd64.tar.gz"
      sha256 "60252e5f6d59af2ae926ab6c3458f48bb918ccca9c06263294ad4dc83a94afbd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1517/agentshield_0.2.1517_darwin_arm64.tar.gz"
      sha256 "543f9c62f8996c2ca7776e1b26b1fb05710a65c050d8322538c6f7d62cbf58a6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1517/agentshield_0.2.1517_linux_amd64.tar.gz"
      sha256 "6013f7e8eb588f97089a49d64ce8da885983a7ec0f6b4a902670d8f546e870ca"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1517/agentshield_0.2.1517_linux_arm64.tar.gz"
      sha256 "445c4e6ea0e693c45b735e699eaba11c0e3dfe88f8e0b0062587f797992ffb4c"
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
