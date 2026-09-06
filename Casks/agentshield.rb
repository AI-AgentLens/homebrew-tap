cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2061"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2061/agentshield_0.2.2061_darwin_amd64.tar.gz"
      sha256 "cb287a699d05fa72a905a72c66541c487c34b624a66aac269a7dd704e2d85a13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2061/agentshield_0.2.2061_darwin_arm64.tar.gz"
      sha256 "2ffedd946b524018f77c265c9ab0a48dadbff65c446c6dfc4a2e1404db3426e3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2061/agentshield_0.2.2061_linux_amd64.tar.gz"
      sha256 "fceab8bd13bd4ce2a9460f8a89f5b4e0377cfb77e2aaeb357d641d3a9abe5bd4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2061/agentshield_0.2.2061_linux_arm64.tar.gz"
      sha256 "707d44ee1c23eb6e46029f0593357c9121f109e0cbd8d4b99f0ea427a61e084c"
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
