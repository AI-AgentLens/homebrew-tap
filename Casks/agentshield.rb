cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1491"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1491/agentshield_0.2.1491_darwin_amd64.tar.gz"
      sha256 "e388854221e42d86c70fd2eafe2ae651ac850b9b0d8390eccc070328ccec0056"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1491/agentshield_0.2.1491_darwin_arm64.tar.gz"
      sha256 "cc3af8e940a4293b8f32c66dc4b7092e40c9978adeac1efb4960f648f2fcd9f4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1491/agentshield_0.2.1491_linux_amd64.tar.gz"
      sha256 "53ee081c6ecff9a287ecf0b51ef4162a45912a89b301e0f83835ff4a54d006e4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1491/agentshield_0.2.1491_linux_arm64.tar.gz"
      sha256 "c4743f79efa1b17d506d8be8846fa85cfff7ab11cc48e9770fad3b26025bd17d"
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
