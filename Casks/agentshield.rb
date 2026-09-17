cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2167"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2167/agentshield_0.2.2167_darwin_amd64.tar.gz"
      sha256 "0bd2e46fdab1c61dabc19cce74a695e00c35886d2a15a3fdfbdb620b1a3574cf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2167/agentshield_0.2.2167_darwin_arm64.tar.gz"
      sha256 "d2a021af71c9bda1cb5aff5449d710dba31068cf433b354a7d5e55e87270bdf3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2167/agentshield_0.2.2167_linux_amd64.tar.gz"
      sha256 "8ed62a041e089a7ef910d687a9ff818ea2a900f3ce1aa2510ffeec2930ac2e42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2167/agentshield_0.2.2167_linux_arm64.tar.gz"
      sha256 "84cbeaa7e85fc763c0148ddc00da8b5957756d8c097fd180ad32d9fb48d5626a"
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
