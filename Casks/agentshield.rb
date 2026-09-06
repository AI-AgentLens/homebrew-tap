cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2053"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2053/agentshield_0.2.2053_darwin_amd64.tar.gz"
      sha256 "a321abde263621608df29ffde4874d687f0033a751e1d0133c68e6e768cedbd3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2053/agentshield_0.2.2053_darwin_arm64.tar.gz"
      sha256 "a046029aa64500d6604a5ee110d6ca0b45329c7a4ca1c4fc0bd1d767e0d62c9e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2053/agentshield_0.2.2053_linux_amd64.tar.gz"
      sha256 "0bf4141bf2328d1da780a54541028fc1317cc0f4c6ae9d0b441a39b7bf35fe07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2053/agentshield_0.2.2053_linux_arm64.tar.gz"
      sha256 "cf38c7a179f09048aaae848affeff0e6aa8cb8a4a464b3e9b9e129691260cdae"
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
