cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1853"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1853/agentshield_0.2.1853_darwin_amd64.tar.gz"
      sha256 "9d76791cb58a5528cca91bf12a5e23e1250b0dca0f4d677d0f2a8a6569b826f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1853/agentshield_0.2.1853_darwin_arm64.tar.gz"
      sha256 "954bc9c5ff5eb0fd11a0667a404fa03436b33c49d08e1e7325426bfd7bcbebd2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1853/agentshield_0.2.1853_linux_amd64.tar.gz"
      sha256 "ca486515d33a8da9c016fe2fd0f3c4a24be14a8af92bad48291f522454b7703c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1853/agentshield_0.2.1853_linux_arm64.tar.gz"
      sha256 "09d5fffe55389dd331f246846597d3b11b70bd4820835133ced1dbf982154746"
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
