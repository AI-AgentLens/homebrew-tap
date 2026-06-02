cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1197"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1197/agentshield_0.2.1197_darwin_amd64.tar.gz"
      sha256 "120295aa80f821eed2268a7dde210abc8d4705fdaf9017cc39e0401c084308b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1197/agentshield_0.2.1197_darwin_arm64.tar.gz"
      sha256 "ac233ac0a3acab66edc77e8e527053d7408be3de34d380351bfe5f026ad9a77a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1197/agentshield_0.2.1197_linux_amd64.tar.gz"
      sha256 "4ab262da355dbe5545672673d0d890156ba6dbdcfae2715dff5b5b058f464855"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1197/agentshield_0.2.1197_linux_arm64.tar.gz"
      sha256 "53aca2276d31fb7bdea788e74084c177357833b5b5cb31f4c39d031fc66cbe84"
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
