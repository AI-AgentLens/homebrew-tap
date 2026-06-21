cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1391"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1391/agentshield_0.2.1391_darwin_amd64.tar.gz"
      sha256 "ced9deac6f41a0cf1f60646043502942b6f687d8d8845251867975fe93eb05de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1391/agentshield_0.2.1391_darwin_arm64.tar.gz"
      sha256 "80329474ab0ddc14a478b8397aea5117e57572a07b10810636a5ac7e3c307858"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1391/agentshield_0.2.1391_linux_amd64.tar.gz"
      sha256 "184f4e02faee2aa6df4f0949dd7eeb9961073b1342b6a7afb3e806b30c6894c5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1391/agentshield_0.2.1391_linux_arm64.tar.gz"
      sha256 "f37befa6172215a964354c50b34e2222a6126b9fb1456804cb43c91545c98dbf"
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
