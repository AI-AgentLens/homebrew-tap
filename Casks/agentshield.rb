cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2466"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2466/agentshield_0.2.2466_darwin_amd64.tar.gz"
      sha256 "af81b6a143d924028194cfe828927ba97cc4b9db9676e406d950b4a9438f8f41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2466/agentshield_0.2.2466_darwin_arm64.tar.gz"
      sha256 "b3d2b8f8361bcaf52fca5607ae110e1d31944b9bdfbd07462c4e5d74c2bd33c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2466/agentshield_0.2.2466_linux_amd64.tar.gz"
      sha256 "8c4a47be018e0ef9a7785b45220571ee76d0149b3c4366ea3d99b3780f1c7850"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2466/agentshield_0.2.2466_linux_arm64.tar.gz"
      sha256 "17605dfc7f8eeb4211821104397b9e5952edad742d14988d0bd35f70ae38251f"
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
