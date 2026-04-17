cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.624"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.624/agentshield_0.2.624_darwin_amd64.tar.gz"
      sha256 "57e2bad26cd878c10069a3143d86ee5f9aeaaacb8e51d2e72fbadfb22335f1dd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.624/agentshield_0.2.624_darwin_arm64.tar.gz"
      sha256 "14c174a240fa5532268c71840d8106602ae2f45b6a05112ca6884e968de780cf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.624/agentshield_0.2.624_linux_amd64.tar.gz"
      sha256 "34942e7eb47fa37ca94a72d24791e83b413c923df4625f6221fc9b023b26a24b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.624/agentshield_0.2.624_linux_arm64.tar.gz"
      sha256 "d49ffe9b8fe6ddc3397146896f1d9e86119322469c2745713b8090589814bfd6"
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
